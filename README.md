# flirmod

# install

-   rename `.env.template` file to `.env` and replace `XXXXXXXXX` with your serial id (as found on camera)

-   download and install node: https://nodejs.org (tested with v21)

-   install dependencies:

```bash
npm install
```

# run

```bash
npm run dev
```

# limitations

-   Tested on Windows and WSL.
-   Only works for Flir E4 that is connected to local WIFI
-   Currently only downloads all Flir files to a local folder. Modding is WIP
