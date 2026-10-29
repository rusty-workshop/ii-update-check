# ii-update-check

Notifies when [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)
(the illogical-impulse dots I daily-drive) has new commits on `main`.
Doesn't pull or apply anything — the installer touches system packages and
configs, which isn't something to run unattended. Just a heads-up so
updates don't happen invisibly.

## Usage

```bash
./check-ii-update.sh
```

First run records the current upstream commit as a baseline (no
notification). Every run after that compares against the last-seen SHA
(`~/.cache/ii-update-check/last-seen-sha`) and sends a `notify-send` alert
with a link to the commit log if it's moved.

## Install as a daily timer

```bash
mkdir -p ~/.config/systemd/user
cp systemd/ii-update-check.{service,timer} ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now ii-update-check.timer
```

## License

AGPL-3.0-or-later.
