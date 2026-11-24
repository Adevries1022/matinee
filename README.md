# Matinee: a Jellyfin app for Roku

Matinee is a free Roku app for watching your own [Jellyfin](https://jellyfin.org) server, with a calm, Netflix-style home screen, trailers that play behind the title you're on, and a fast player. If you use [Seerr](https://github.com/seerr-team/seerr), you can also browse and request new movies and shows from the TV.

It works on Roku TVs and Roku sticks and boxes, including entry-level ones.

Matinee isn't in the Roku Channel Store yet, so you install it yourself from this page. It takes about 10 minutes, and you only need a computer on the same Wi-Fi as your Roku.

## What you need
- A Roku TV, stick or box.
- A Jellyfin server, version 10.9 or newer, that the Roku can reach.
- A computer (Windows, Mac or Linux) on the same network as the Roku. You only need it to install Matinee and to update it.
- Optional: Seerr, for requests.

## Install Matinee

### 1. Turn on Developer Mode on the Roku
You do this once. It lets you install an app that isn't from the Channel Store.

1. With the Roku on its home screen, press these buttons on the remote: **Home** three times, **Up** twice, then **Right, Left, Right, Left, Right**.
2. A Developer Settings screen opens. **Write down the address it shows**, such as `http://192.168.1.50`.
3. Choose **Enable installer and restart**, accept the agreement, and **set a password**. Write it down too.
4. The Roku restarts.

If nothing happens, press the buttons again a little more slowly, starting from the Roku home screen.

### 2. Download Matinee
Download **[matinee.zip](https://github.com/Adevries1022/matinee/releases/latest/download/matinee.zip)** from the latest release. Don't unzip it.

### 3. Install it on the Roku
1. On the computer, open a web browser and go to the address from step 1 (for example `http://192.168.1.50`).
2. Sign in with the username **rokudev** and the password you set.
3. Click **Upload**, choose `matinee.zip`, then click **Install with zip**.
4. Matinee opens on the TV. From now on it's on the Roku home screen with your other apps.

### 4. Connect to your server and sign in
1. **Pick your server.** Matinee lists Jellyfin servers it finds on your network. If yours isn't there, or you use it from outside your home, choose **Enter address** and type it with the port, such as `http://192.168.1.10:8096` or `https://jellyfin.example.com`.
2. **Pick your name** on Who's watching.
3. **Sign in.** Matinee shows a code. On your phone or computer, open Jellyfin, go to your profile → **Quick Connect** and enter the code. Or press OK to type your password instead.

That's it. If several people use Jellyfin, each one picks their name the first time, and Matinee remembers them.

### 5. Requests through Seerr (optional)
If you have Seerr, Matinee looks for it on its own (on port 5055 of the Jellyfin machine, and at a few common names). When it finds it, **Discover** and **My requests** appear in the menu on the left. Each person signs in to Seerr once with their Jellyfin account.

If Discover doesn't appear, a Jellyfin administrator can enter Seerr's address in **Settings › Servers & services › Seerr**.

## Update Matinee
1. Download the latest **[matinee.zip](https://github.com/Adevries1022/matinee/releases/latest/download/matinee.zip)**.
2. Open the Roku's address in a browser again, sign in as **rokudev**, and click **Upload**, then **Replace**.

Your server, sign-ins and settings stay as they were. To hear about new versions, click **Watch → Custom → Releases** at the top of this page.

## Using Matinee
- **Getting around:** press **Left** to open the menu (Search, Home, Series, Movies, My List and more). **Back** goes back; on Home it opens the menu, and Back again leaves Matinee.
- **Title Options:** hold **OK** on any title, or press **\***, to start it over, mark it watched, add it to My List, or remove it from Continue watching.
- **My List** is your Jellyfin Favorites, so it's the same on every device.
- **Trailers** play behind the title you're on when your server has trailers for it. Jellyfin doesn't download trailers by itself; [Trailarr](https://github.com/nandyalu/trailarr) can.
- **Subtitles:** while watching, press **\*** on a Roku stick or box. On a Roku TV, press **Down** twice instead and choose Subtitles, because Roku TVs keep \* for their own menu during video.
- **Settings** has Themes and accent colors, playback quality, subtitle language and more. Each person's choices are their own.

Every feature and remote button is in [docs/features.md](docs/features.md).

## Something's not working

**"Couldn't reach your server"**
- Check that Jellyfin is running: open its address in a browser on your phone.
- Use the full address with the port, such as `http://192.168.1.10:8096`.
- If you use Jellyfin outside your home, the address must work from the Roku's network too. In **Settings › Servers & services** an administrator can add an **away address**, which Matinee tries when the home one doesn't answer.

**The Roku's web page doesn't open**
- Make sure the computer and the Roku are on the same network, and that you typed `http://`, not `https://`.
- Turn Developer Mode on again (step 1); the address may have changed.

**Matinee disappeared from the Roku**
- A Roku holds one app installed this way at a time. Installing another one, or turning Developer Mode off, removes Matinee. Install it again (step 3). You may need to sign in again.

**Video, artwork or trailers don't load on an `https` server**
- The Roku needs a certificate it trusts for video and images. A self-signed certificate works for signing in but not for playback. Use a certificate from Let's Encrypt or another public authority, or the plain `http://` address at home.

**Pictures in subtitles (such as Blu-ray PGS) take a moment**
- The server has to burn them into the video, which needs a little more time to start and more work on the server.

If you're stuck, [open an issue](https://github.com/Adevries1022/matinee/issues) and say which Roku you have, your Jellyfin version, and what you see on screen.

## About
Matinee is free and open source under the [GPL-3.0](LICENSE) licence. It isn't made by or affiliated with Jellyfin, Seerr or Roku.

Want to build it yourself or help out? See [docs/development.md](docs/development.md).
