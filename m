From: Alex Williamson <alex_williamson@attbi.com>
Date: Sun, 28 Apr 2002 14:58:48 +0000
Subject: Re: [Linux-ia64] McKinley keyboard problems.
Message-Id: <marc-linux-ia64-105590701905535@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905534@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905534@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Steffen,

    David's latest 2.4.18 patch set is getting pretty close to fully
functional on the zx1 chipset.  The install kernel from RH is not
going to work since it depends on some legacy I/O features in the Intel
chipsets.  I'd suggest trying Debian.  The latest Debian kernel has the
patch set necessary for this chipset (and it's free!).

	Alex <alex_williamson@hp.com>


Steffen Persvold wrote:
 > Hi all,
 >
 > We just got two HP McKinley systems in our lab, but I'm not able to
 > install them with RH 7.2 (kernel-2.4.9-18) because they only got USB
 > keyboard/mouse. When the kernel boots it complains about "keyboard
 > jammed" and when the RH installer finally starts the keyboard is
 > "dead". Any ideas ? Is this fixed with newer kernels ?
 >
 > Thanks,




