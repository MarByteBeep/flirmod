const bufSize = 64;

type Tuple<T, N extends number, R extends T[] = []> = R['length'] extends N ? R : Tuple<T, N, [T, ...R]>;

export class CRMD160 {
	private mode: number;
	private h0_: number;
	private h1_: number;
	private h2_: number;
	private h3_: number;
	private h4_: number;
	private bufLen_: number;
	private total_: number;
	private buffer_ = new Uint8Array(bufSize);

	constructor(mode: number) {
		this.h0_ = 0;
		this.h1_ = 0;
		this.h2_ = 0;
		this.h3_ = 0;
		this.h4_ = 0;
		this.bufLen_ = 0;
		this.total_ = 0;

		this.mode = mode;
		this.reset();
	}

	private reset(): void {
		switch (this.mode) {
			case 0:
				this.h0_ = 0x67452301;
				this.h1_ = 0xefcdab89;
				this.h2_ = 0x98badcfe;
				this.h3_ = 0x10325476;
				this.h4_ = 0xc3d2e1f0;
				break;

			case 1:
			case 3:
				this.h0_ = 0x3412f0de;
				this.h1_ = 0xab896745;
				this.h2_ = 0x547698ba;
				this.h3_ = 0xed0f2143;
				this.h4_ = 0x9281706f;
				break;

			case 2:
				this.h0_ = 0xd83ab991;
				this.h1_ = 0x296e33c2;
				this.h2_ = 0xf72884b6;
				this.h3_ = 0x96ace345;
				this.h4_ = 0x185682e2;
				break;
		}

		this.bufLen_ = 0;
		this.total_ = 0;

		if (this.mode === 3) {
			const out = Buffer.from(new Uint8Array(CRMD160.getDigestLength()));
			this.update(Buffer.from('ZeP0a_K'));
			this.digest(out);
			this.bufLen_ = 0;
			this.total_ = 0;
		}
	}

	public update(input: Uint8Array): void {
		const len = input.byteLength;

		let left = len + this.bufLen_;
		const buffer = new Uint8Array(bufSize);

		if (bufSize > left) {
			// We have less than bufSize bytes (a block) to hash
			for (let i = 0; i < len; ++i) {
				this.buffer_[this.bufLen_ + i] = input[i];
			}
			this.bufLen_ = left;
			return;
		}

		if (0 < this.bufLen_) {
			// We have data left in the context buffer
			const tmp = bufSize - this.bufLen_;
			for (let i = 0; i < this.bufLen_; i++) {
				buffer[i] = this.buffer_[i];
			}
			for (let i = 0; i < tmp; i++) {
				buffer[this.bufLen_ + i] = input[i];
			}
			this.hashBlock(buffer);
			input = input.slice(tmp);
			left -= bufSize;
			this.total_ += bufSize;
		}

		while (bufSize <= left) {
			// Hash the data block by block
			for (let i = 0; i < bufSize; i++) {
				buffer[i] = input[i];
			}
			this.hashBlock(buffer);
			input = input.slice(bufSize);
			left -= bufSize;
			this.total_ += bufSize;
		}

		// Copy the data left to the context buffer
		if (0 !== left) {
			for (let i = 0; i < left; i++) {
				this.buffer_[i] = input[i];
			}
		}
		this.bufLen_ = left;
	}

	public digest(out: Buffer): void {
		// Hash the last block
		this.total_ += this.bufLen_;
		this.buffer_.fill(0, this.bufLen_, bufSize - this.bufLen_);

		/* FLIR doesn't have proper padding ... */
		// Uncomment the following lines if needed
		// this.buffer_[this.bufLen_] ^= 0x80;
		// if (55 < this.bufLen_) {
		//     this.hashBlock(this.buffer_);
		//     this.buffer_.fill(0, 0, bufSize);
		// }
		// *(this.buffer_.subarray(14, 16)) = this.total_ << 3;
		// *(this.buffer_.subarray(15, 17)) = this.total_ >>> 29;

		this.hashBlock(this.buffer_);

		// Generate the digest
		out.writeUInt32LE(this.h0_ >>> 0, 0);
		out.writeUInt32LE(this.h1_ >>> 0, 4);
		out.writeUInt32LE(this.h2_ >>> 0, 8);
		out.writeUInt32LE(this.h3_ >>> 0, 12);
		out.writeUInt32LE(this.h4_ >>> 0, 16);
	}

	public static getDigestLength(): number {
		return 20; // Length of the digest in bytes
	}

	private hashBlock(block: Uint8Array): void {
		type RNDInput = Tuple<number, 5>;

		const inbuf = new Uint32Array(block.buffer);

		// cyclic left shift x over n positions
		const ROL = (x: number, n: number): number => (x << n) | (x >>> (32 - n));

		// nonlinear functions for each round
		const F1 = (x: number, y: number, z: number): number => x ^ y ^ z;
		const F2 = (x: number, y: number, z: number): number => (x & y) | (~x & z);
		const F3 = (x: number, y: number, z: number): number => (x | ~y) ^ z;
		const F4 = (x: number, y: number, z: number): number => (x & z) | (y & ~z);
		const F5 = (x: number, y: number, z: number): number => x ^ (y | ~z);

		function RND(
			input: RNDInput,
			shuffle: RNDInput,
			f: (x: number, y: number, z: number) => number,
			x: number,
			s: number,
			k: number
		) {
			input[shuffle[0]] += f(input[shuffle[1]], input[shuffle[2]], input[shuffle[3]]) + x + k;
			input[shuffle[0]] = ROL(input[shuffle[0]], s) + input[shuffle[4]];
			input[shuffle[2]] = ROL(input[shuffle[2]], 10);
		}

		// left rounds
		const left: RNDInput = [this.h0_, this.h1_, this.h2_, this.h3_, this.h4_];

		// round 1
		RND(left, [0, 1, 2, 3, 4], F1, inbuf[0], 11, 0);
		RND(left, [4, 0, 1, 2, 3], F1, inbuf[1], 14, 0);
		RND(left, [3, 4, 0, 1, 2], F1, inbuf[2], 15, 0);
		RND(left, [2, 3, 4, 0, 1], F1, inbuf[3], 12, 0);
		RND(left, [1, 2, 3, 4, 0], F1, inbuf[4], 5, 0);
		RND(left, [0, 1, 2, 3, 4], F1, inbuf[5], 8, 0);
		RND(left, [4, 0, 1, 2, 3], F1, inbuf[6], 7, 0);
		RND(left, [3, 4, 0, 1, 2], F1, inbuf[7], 9, 0);
		RND(left, [2, 3, 4, 0, 1], F1, inbuf[8], 11, 0);
		RND(left, [1, 2, 3, 4, 0], F1, inbuf[9], 13, 0);
		RND(left, [0, 1, 2, 3, 4], F1, inbuf[10], 14, 0);
		RND(left, [4, 0, 1, 2, 3], F1, inbuf[11], 15, 0);
		RND(left, [3, 4, 0, 1, 2], F1, inbuf[12], 6, 0);
		RND(left, [2, 3, 4, 0, 1], F1, inbuf[13], 7, 0);
		RND(left, [1, 2, 3, 4, 0], F1, inbuf[14], 9, 0);
		RND(left, [0, 1, 2, 3, 4], F1, inbuf[15], 8, 0);

		// round 2
		RND(left, [4, 0, 1, 2, 3], F2, inbuf[7], 7, 0x5a827999);
		RND(left, [3, 4, 0, 1, 2], F2, inbuf[4], 6, 0x5a827999);
		RND(left, [2, 3, 4, 0, 1], F2, inbuf[13], 8, 0x5a827999);
		RND(left, [1, 2, 3, 4, 0], F2, inbuf[1], 13, 0x5a827999);
		RND(left, [0, 1, 2, 3, 4], F2, inbuf[10], 11, 0x5a827999);
		RND(left, [4, 0, 1, 2, 3], F2, inbuf[6], 9, 0x5a827999);
		RND(left, [3, 4, 0, 1, 2], F2, inbuf[15], 7, 0x5a827999);
		RND(left, [2, 3, 4, 0, 1], F2, inbuf[3], 15, 0x5a827999);
		RND(left, [1, 2, 3, 4, 0], F2, inbuf[12], 7, 0x5a827999);
		RND(left, [0, 1, 2, 3, 4], F2, inbuf[0], 12, 0x5a827999);
		RND(left, [4, 0, 1, 2, 3], F2, inbuf[9], 15, 0x5a827999);
		RND(left, [3, 4, 0, 1, 2], F2, inbuf[5], 9, 0x5a827999);
		RND(left, [2, 3, 4, 0, 1], F2, inbuf[2], 11, 0x5a827999);
		RND(left, [1, 2, 3, 4, 0], F2, inbuf[14], 7, 0x5a827999);
		RND(left, [0, 1, 2, 3, 4], F2, inbuf[11], 13, 0x5a827999);
		RND(left, [4, 0, 1, 2, 3], F2, inbuf[8], 12, 0x5a827999);

		// round 3
		RND(left, [3, 4, 0, 1, 2], F3, inbuf[3], 11, 0x6ed9eba1);
		RND(left, [2, 3, 4, 0, 1], F3, inbuf[10], 13, 0x6ed9eba1);
		RND(left, [1, 2, 3, 4, 0], F3, inbuf[14], 6, 0x6ed9eba1);
		RND(left, [0, 1, 2, 3, 4], F3, inbuf[4], 7, 0x6ed9eba1);
		RND(left, [4, 0, 1, 2, 3], F3, inbuf[9], 14, 0x6ed9eba1);
		RND(left, [3, 4, 0, 1, 2], F3, inbuf[15], 9, 0x6ed9eba1);
		RND(left, [2, 3, 4, 0, 1], F3, inbuf[8], 13, 0x6ed9eba1);
		RND(left, [1, 2, 3, 4, 0], F3, inbuf[1], 15, 0x6ed9eba1);
		RND(left, [0, 1, 2, 3, 4], F3, inbuf[2], 14, 0x6ed9eba1);
		RND(left, [4, 0, 1, 2, 3], F3, inbuf[7], 8, 0x6ed9eba1);
		RND(left, [3, 4, 0, 1, 2], F3, inbuf[0], 13, 0x6ed9eba1);
		RND(left, [2, 3, 4, 0, 1], F3, inbuf[6], 6, 0x6ed9eba1);
		RND(left, [1, 2, 3, 4, 0], F3, inbuf[13], 5, 0x6ed9eba1);
		RND(left, [0, 1, 2, 3, 4], F3, inbuf[11], 12, 0x6ed9eba1);
		RND(left, [4, 0, 1, 2, 3], F3, inbuf[5], 7, 0x6ed9eba1);
		RND(left, [3, 4, 0, 1, 2], F3, inbuf[12], 5, 0x6ed9eba1);

		// round 4
		RND(left, [2, 3, 4, 0, 1], F4, inbuf[1], 11, 0x8f1bbcdc);
		RND(left, [1, 2, 3, 4, 0], F4, inbuf[9], 12, 0x8f1bbcdc);
		RND(left, [0, 1, 2, 3, 4], F4, inbuf[11], 14, 0x8f1bbcdc);
		RND(left, [4, 0, 1, 2, 3], F4, inbuf[10], 15, 0x8f1bbcdc);
		RND(left, [3, 4, 0, 1, 2], F4, inbuf[0], 14, 0x8f1bbcdc);
		RND(left, [2, 3, 4, 0, 1], F4, inbuf[8], 15, 0x8f1bbcdc);
		RND(left, [1, 2, 3, 4, 0], F4, inbuf[12], 9, 0x8f1bbcdc);
		RND(left, [0, 1, 2, 3, 4], F4, inbuf[4], 8, 0x8f1bbcdc);
		RND(left, [4, 0, 1, 2, 3], F4, inbuf[13], 9, 0x8f1bbcdc);
		RND(left, [3, 4, 0, 1, 2], F4, inbuf[3], 14, 0x8f1bbcdc);
		RND(left, [2, 3, 4, 0, 1], F4, inbuf[7], 5, 0x8f1bbcdc);
		RND(left, [1, 2, 3, 4, 0], F4, inbuf[15], 6, 0x8f1bbcdc);
		RND(left, [0, 1, 2, 3, 4], F4, inbuf[14], 8, 0x8f1bbcdc);
		RND(left, [4, 0, 1, 2, 3], F4, inbuf[5], 6, 0x8f1bbcdc);
		RND(left, [3, 4, 0, 1, 2], F4, inbuf[6], 5, 0x8f1bbcdc);
		RND(left, [2, 3, 4, 0, 1], F4, inbuf[2], 12, 0x8f1bbcdc);

		// round 5
		RND(left, [1, 2, 3, 4, 0], F5, inbuf[4], 9, 0xa953fd4e);
		RND(left, [0, 1, 2, 3, 4], F5, inbuf[0], 15, 0xa953fd4e);
		RND(left, [4, 0, 1, 2, 3], F5, inbuf[5], 5, 0xa953fd4e);
		RND(left, [3, 4, 0, 1, 2], F5, inbuf[9], 11, 0xa953fd4e);
		RND(left, [2, 3, 4, 0, 1], F5, inbuf[7], 6, 0xa953fd4e);
		RND(left, [1, 2, 3, 4, 0], F5, inbuf[12], 8, 0xa953fd4e);
		RND(left, [0, 1, 2, 3, 4], F5, inbuf[2], 13, 0xa953fd4e);
		RND(left, [4, 0, 1, 2, 3], F5, inbuf[10], 12, 0xa953fd4e);
		RND(left, [3, 4, 0, 1, 2], F5, inbuf[14], 5, 0xa953fd4e);
		RND(left, [2, 3, 4, 0, 1], F5, inbuf[1], 12, 0xa953fd4e);
		RND(left, [1, 2, 3, 4, 0], F5, inbuf[3], 13, 0xa953fd4e);
		RND(left, [0, 1, 2, 3, 4], F5, inbuf[8], 14, 0xa953fd4e);
		RND(left, [4, 0, 1, 2, 3], F5, inbuf[11], 11, 0xa953fd4e);
		RND(left, [3, 4, 0, 1, 2], F5, inbuf[6], 8, 0xa953fd4e);
		RND(left, [2, 3, 4, 0, 1], F5, inbuf[15], 5, 0xa953fd4e);
		RND(left, [1, 2, 3, 4, 0], F5, inbuf[13], 6, 0xa953fd4e);

		// right rounds
		const right: RNDInput = [this.h0_, this.h1_, this.h2_, this.h3_, this.h4_];

		// round 1
		RND(right, [0, 1, 2, 3, 4], F5, inbuf[5], 8, 0x50a28be6);
		RND(right, [4, 0, 1, 2, 3], F5, inbuf[14], 9, 0x50a28be6);
		RND(right, [3, 4, 0, 1, 2], F5, inbuf[7], 9, 0x50a28be6);
		RND(right, [2, 3, 4, 0, 1], F5, inbuf[0], 11, 0x50a28be6);
		RND(right, [1, 2, 3, 4, 0], F5, inbuf[9], 13, 0x50a28be6);
		RND(right, [0, 1, 2, 3, 4], F5, inbuf[2], 15, 0x50a28be6);
		RND(right, [4, 0, 1, 2, 3], F5, inbuf[11], 15, 0x50a28be6);
		RND(right, [3, 4, 0, 1, 2], F5, inbuf[4], 5, 0x50a28be6);
		RND(right, [2, 3, 4, 0, 1], F5, inbuf[13], 7, 0x50a28be6);
		RND(right, [1, 2, 3, 4, 0], F5, inbuf[6], 7, 0x50a28be6);
		RND(right, [0, 1, 2, 3, 4], F5, inbuf[15], 8, 0x50a28be6);
		RND(right, [4, 0, 1, 2, 3], F5, inbuf[8], 11, 0x50a28be6);
		RND(right, [3, 4, 0, 1, 2], F5, inbuf[1], 14, 0x50a28be6);
		RND(right, [2, 3, 4, 0, 1], F5, inbuf[10], 14, 0x50a28be6);
		RND(right, [1, 2, 3, 4, 0], F5, inbuf[3], 12, 0x50a28be6);
		RND(right, [0, 1, 2, 3, 4], F5, inbuf[12], 6, 0x50a28be6);

		// round 2
		RND(right, [4, 0, 1, 2, 3], F4, inbuf[6], 9, 0x5c4dd124);
		RND(right, [3, 4, 0, 1, 2], F4, inbuf[11], 13, 0x5c4dd124);
		RND(right, [2, 3, 4, 0, 1], F4, inbuf[3], 15, 0x5c4dd124);
		RND(right, [1, 2, 3, 4, 0], F4, inbuf[7], 7, 0x5c4dd124);
		RND(right, [0, 1, 2, 3, 4], F4, inbuf[0], 12, 0x5c4dd124);
		RND(right, [4, 0, 1, 2, 3], F4, inbuf[13], 8, 0x5c4dd124);
		RND(right, [3, 4, 0, 1, 2], F4, inbuf[5], 9, 0x5c4dd124);
		RND(right, [2, 3, 4, 0, 1], F4, inbuf[10], 11, 0x5c4dd124);
		RND(right, [1, 2, 3, 4, 0], F4, inbuf[14], 7, 0x5c4dd124);
		RND(right, [0, 1, 2, 3, 4], F4, inbuf[15], 7, 0x5c4dd124);
		RND(right, [4, 0, 1, 2, 3], F4, inbuf[8], 12, 0x5c4dd124);
		RND(right, [3, 4, 0, 1, 2], F4, inbuf[12], 7, 0x5c4dd124);
		RND(right, [2, 3, 4, 0, 1], F4, inbuf[4], 6, 0x5c4dd124);
		RND(right, [1, 2, 3, 4, 0], F4, inbuf[9], 15, 0x5c4dd124);
		RND(right, [0, 1, 2, 3, 4], F4, inbuf[1], 13, 0x5c4dd124);
		RND(right, [4, 0, 1, 2, 3], F4, inbuf[2], 11, 0x5c4dd124);

		// round 3
		RND(right, [3, 4, 0, 1, 2], F3, inbuf[15], 9, 0x6d703ef3);
		RND(right, [2, 3, 4, 0, 1], F3, inbuf[5], 7, 0x6d703ef3);
		RND(right, [1, 2, 3, 4, 0], F3, inbuf[1], 15, 0x6d703ef3);
		RND(right, [0, 1, 2, 3, 4], F3, inbuf[3], 11, 0x6d703ef3);
		RND(right, [4, 0, 1, 2, 3], F3, inbuf[7], 8, 0x6d703ef3);
		RND(right, [3, 4, 0, 1, 2], F3, inbuf[14], 6, 0x6d703ef3);
		RND(right, [2, 3, 4, 0, 1], F3, inbuf[6], 6, 0x6d703ef3);
		RND(right, [1, 2, 3, 4, 0], F3, inbuf[9], 14, 0x6d703ef3);
		RND(right, [0, 1, 2, 3, 4], F3, inbuf[11], 12, 0x6d703ef3);
		RND(right, [4, 0, 1, 2, 3], F3, inbuf[8], 13, 0x6d703ef3);
		RND(right, [3, 4, 0, 1, 2], F3, inbuf[12], 5, 0x6d703ef3);
		RND(right, [2, 3, 4, 0, 1], F3, inbuf[2], 14, 0x6d703ef3);
		RND(right, [1, 2, 3, 4, 0], F3, inbuf[10], 13, 0x6d703ef3);
		RND(right, [0, 1, 2, 3, 4], F3, inbuf[0], 13, 0x6d703ef3);
		RND(right, [4, 0, 1, 2, 3], F3, inbuf[4], 7, 0x6d703ef3);
		RND(right, [3, 4, 0, 1, 2], F3, inbuf[13], 5, 0x6d703ef3);

		// round 4
		RND(right, [2, 3, 4, 0, 1], F2, inbuf[8], 15, 0x7a6d76e9);
		RND(right, [1, 2, 3, 4, 0], F2, inbuf[6], 5, 0x7a6d76e9);
		RND(right, [0, 1, 2, 3, 4], F2, inbuf[4], 8, 0x7a6d76e9);
		RND(right, [4, 0, 1, 2, 3], F2, inbuf[1], 11, 0x7a6d76e9);
		RND(right, [3, 4, 0, 1, 2], F2, inbuf[3], 14, 0x7a6d76e9);
		RND(right, [2, 3, 4, 0, 1], F2, inbuf[11], 14, 0x7a6d76e9);
		RND(right, [1, 2, 3, 4, 0], F2, inbuf[15], 6, 0x7a6d76e9);
		RND(right, [0, 1, 2, 3, 4], F2, inbuf[0], 14, 0x7a6d76e9);
		RND(right, [4, 0, 1, 2, 3], F2, inbuf[5], 6, 0x7a6d76e9);
		RND(right, [3, 4, 0, 1, 2], F2, inbuf[12], 9, 0x7a6d76e9);
		RND(right, [2, 3, 4, 0, 1], F2, inbuf[2], 12, 0x7a6d76e9);
		RND(right, [1, 2, 3, 4, 0], F2, inbuf[13], 9, 0x7a6d76e9);
		RND(right, [0, 1, 2, 3, 4], F2, inbuf[9], 12, 0x7a6d76e9);
		RND(right, [4, 0, 1, 2, 3], F2, inbuf[7], 5, 0x7a6d76e9);
		RND(right, [3, 4, 0, 1, 2], F2, inbuf[10], 15, 0x7a6d76e9);
		RND(right, [2, 3, 4, 0, 1], F2, inbuf[14], 8, 0x7a6d76e9);

		// round 5
		RND(right, [1, 2, 3, 4, 0], F1, inbuf[12], 8, 0);
		RND(right, [0, 1, 2, 3, 4], F1, inbuf[15], 5, 0);
		RND(right, [4, 0, 1, 2, 3], F1, inbuf[10], 12, 0);
		RND(right, [3, 4, 0, 1, 2], F1, inbuf[4], 9, 0);
		RND(right, [2, 3, 4, 0, 1], F1, inbuf[1], 12, 0);
		RND(right, [1, 2, 3, 4, 0], F1, inbuf[5], 5, 0);
		RND(right, [0, 1, 2, 3, 4], F1, inbuf[8], 14, 0);
		RND(right, [4, 0, 1, 2, 3], F1, inbuf[7], 6, 0);
		RND(right, [3, 4, 0, 1, 2], F1, inbuf[6], 8, 0);
		RND(right, [2, 3, 4, 0, 1], F1, inbuf[2], 13, 0);
		RND(right, [1, 2, 3, 4, 0], F1, inbuf[13], 6, 0);
		RND(right, [0, 1, 2, 3, 4], F1, inbuf[14], 5, 0);
		RND(right, [4, 0, 1, 2, 3], F1, inbuf[0], 15, 0);
		RND(right, [3, 4, 0, 1, 2], F1, inbuf[3], 13, 0);
		RND(right, [2, 3, 4, 0, 1], F1, inbuf[9], 11, 0);
		RND(right, [1, 2, 3, 4, 0], F1, inbuf[11], 11, 0);

		// combine the two parts
		right[3] += this.h1_ + left[2];
		this.h1_ = this.h2_ + left[3] + right[4];
		this.h2_ = this.h3_ + left[4] + right[0];
		this.h3_ = this.h4_ + left[0] + right[1];
		this.h4_ = this.h0_ + left[1] + right[2];
		this.h0_ = right[3];
	}
}
