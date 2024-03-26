export function RC4(data: Buffer, key: Buffer): Buffer {
	let x = 0;
	const box = Array.from({ length: 256 }, (_, i) => i);

	for (let i = 0; i < 256; i++) {
		x = (x + box[i] + key[i % key.length]) & 255;
		[box[i], box[x]] = [box[x], box[i]];
	}
	let y = 0;
	x = 0;
	const out: Uint8Array = data.map((e) => {
		x = (x + 1) & 255;
		y = (y + box[x]) & 255;
		[box[x], box[y]] = [box[y], box[x]];
		return e ^ box[(box[x] + box[y]) & 255];
	});
	return Buffer.from(out);
}
