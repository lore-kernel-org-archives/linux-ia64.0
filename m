From: Erich Focht <focht@ess.nec.de>
Date: Tue, 15 Jan 2002 09:28:05 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="-1916692341-230195537-1011086885=:26388"
Message-Id: <marc-linux-ia64-105590698805830@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
To: linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1916692341-230195537-1011086885=:26388
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi Nick,

maybe the defconfig-bigsur-mp is a bit old, I could not find any
definition of CONFIG_IA64_GRANULE_64MB or CONFIG_IA64_GRANULE_16MB which
actually would mean that IA64_GRANULE_SIZE could be wrong. I attached a
gzipped diff of the two configs, I had only minor changes to the
default arch/ia64/defconfig. ACPI is definitely configured in.

On Mon, 14 Jan 2002, Nick Pollitt wrote:

> What .config are you using?  I grabbed the defconfig-bigsur-mp
> and compiled with your patch (had to disable DEVFS_DEBUG).  The
> kernel doesn't get very far into the boot, less than a second,
> and it fails.  Of course you said it would.  But I couldn't get
> any useful info from the console so I ran the kernel in medusa.

I don't have medusa and that's not free, I suppose...

> In case you try this, it executes to about 15301000.  Then it
> fails in acpi_hw_low_level_read.  I also tried with the kernel
> patch I sent out Friday, which dies much sooner than this.  But
> it's definitely not getting into schedule in my machine.
> 
> Did you config off other stuff (all the ACPI)? 
> 
> Nick

Regards,

Erich


---1916692341-230195537-1011086885=:26388
Content-Type: APPLICATION/x-gunzip; name="BigSur_config.diff.gz"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.21.0201151028050.26388@sx6.ess.nec.de>
Content-Description: 
Content-Disposition: attachment; filename="BigSur_config.diff.gz"

H4sICGfrQzwCA0JpZ1N1cl9jb25maWcuZGlmZgCNWluTm7gSfs+voOo8nKSK
ZBGIi09ttkqA7NGai4PA45kXimAy643HnjO29yT//jRgexA2ch5SmVF/fVGr
1epuRi/1d78r/1LIYb99LvarslivfypP1aZ6LfbVUnkuvldKud18Wz39R1lu
N//eK9VytX/38ePHd39I+L7+bFmfq83hCjsySmSoyGx0e3E0ZpM8jP0soFxZ
7ZTNdq/sqpMWkf75Z6P4bXFOE87iSGA8M00BABwYldgAZcdVlpKIZWHu8pTO
cj6jHhszD3CnbUlxXUXYUDEusbCRKAtJF9MhMWLhPPTI4CZPgNpmS8XOElsd
s2viHZnTnD9EXhJH7JH6YGRt+Rnk0/mY52N+ueZTN5vAsolLU+9aRccsn5Nk
2PUnADBbWmk6XWaXReMwzUPGvUH+DgZE2Ki0Rl0RM4/lEQklZ39GALtjqA4u
HaQ6hiCEeFOaDvg9omnAoumw/Ia5CS1hJQ9DMusuHwXVHq1NsUpHOPoxC1Ka
DKppycA4MoqR0Y00ksz8LttopCJNL0e1n2oFjZL2p16MzgMS5Y6moy9dfmSg
JdJtwUHRzGWx4GOEdbiH4nEGzebyII5nw+fZAcFuEMYqwmaJsAb/69fEJSQc
OJoTgkUsTfybKkFQ9zw6yzmH6/AZayPrktwKr021HRU54Bsbdz07W1fFrgKt
leJvywNkrT0kte3mt9Wy+rT/sVe+bV+Vv6r1y2+rzbetst0ozKfK8nX1T7Vr
hCAHtm8LngSEz/g0D7MgZXWiosO3/gJamwoxoGuQKEdXPQo83ONM9Op5Q7V5
5V+rF1hWdoeXl+3r/revh6dvqx9Hg6869ygTlOvaCBT391NfQ35HEpqz5Its
NwKwFqePSh1dDbQZY4ubp16DajEQZLqBB9zROI7flHVG1gJNpOqWttSNNiGR
9b563cALpiBjhE+eO3v1KGnREK87/k1CczpDEgaOTrcw2GMv9eYWnbm6opT9
z5dKeb9c7b6ryr54qVTF8z8mcfihlWCDBBu8jSF6TE2Qsn0+WrWs/lmV1U55
X316+gTsyt+H79XX7Y8PZyXPh/V+9bKulCCLdn3raxnta5J/yWgm+vx3AdVG
NAg5P65DMsR3XWTuytdHqNAt4wJMiJcQJiQQA+mFDgm6D+UPoWl4zmKR6wIc
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
xCMAAA==
---1916692341-230195537-1011086885=:26388--

