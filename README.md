On fedora to get autologin I ran this command

`sudo systemctl edit getty@tty1.service`

and added this to the file

```bash
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin username %I $TERM
```
