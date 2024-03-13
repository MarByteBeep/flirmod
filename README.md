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

If the installation was successful, you should get a CLI options menu like this;

![cli](https://github.com/MarByteBeep/flirmod/assets/58225562/81ffc2d3-b2a2-46d9-9fcd-3ded6cdd2486)

# limitations

-   Tested on Windows and WSL.
-   Only works for Flir E4 that is connected to local WIFI
-   Currently only downloads all Flir files to a local folder. Modding is WIP
