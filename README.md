# flirmod

# install

-   rename `.env.template` file to `.env` and replace `XXXXXXXXX` with your serial id (as found on camera)

-   install bun: https://bun.sh/

-   install dependencies:

```bash
bun install
```

# run

```bash
bun run index.ts
```

# limitations

-   Tested only on Windows. Doesn't run on WSL (yet?)
-   Only works for Flir E4 that is connected to local WIFI
-   Currently only downloads all Flir files to a local folder
