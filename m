From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 09 Mar 2005 18:59:52 +0000
Subject: Re: [PATCH] Documentation update about pal_halt_light
Message-Id: <16943.18344.12333.503614@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422F1246.80008@lifl.fr>
In-Reply-To: <422F1246.80008@lifl.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 09 Mar 2005 16:12:06 +0100, Eric Piel <Eric.Piel@lifl.fr> said:

  Eric> Hello, I had to hang around in the code to find this
  Eric> invaluable option "nohalt". Let's document it!

  Eric> That's a trivial documentation update, please apply.

Good catch.  I thought it was documented already.  Perhaps it got
lost.  In any case, I think it would be good to mention why someone
might want to turn it on.  Perhaps something along the lines of:

	"This increases power-consumption.  On the positive side, it
	 reduces interrupt wake-up latency, which may improve
	 performance in certain environments such as networked
	 servers."

  --david

  Eric> -- Documentation update about pal_halt_light on IA-64

  Eric> Signed-off-by: Eric Piel <eric.piel@lifl.fr> -- ---
  Eric> kernel-parameters.txt.bak 2005-03-09 15:39:10.348323818 +0100
  Eric> +++ kernel-parameters.txt 2005-03-09 15:55:19.583141065 +0100
  Eric> @@ -837,6 +837,9 @@ instruction doesn't work correctly and not
  Eric> to use it.
 
  Eric> + nohalt [IA-64] Tells the kernel not to use the power saving
  Eric> + function PAL_HALT_LIGHT when idle.  + noirqdebug [IA-32]
  Eric> Disables the code which attempts to detect and disable
  Eric> unhandled interrupt sources.
 
