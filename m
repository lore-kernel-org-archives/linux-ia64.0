From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Apr 2003 22:27:57 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.67)
Message-Id: <marc-linux-ia64-105590723705509@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 15 Apr 2003 18:01:48 +0900 (JST), Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp> said:

  >> Thanks to Alex's fixes for PCI segment support, we could boot
  >> 2.5.67 kernel on Tiger.  But a strange thing is happening.  Only
  >> cpu0 & 1 are getting timer interrupts and cpu 2 & 3 aren't.  This
  >> problem is reproducible and we see this phenomenon after every
  >> boot.  It seems that these cpus stop receiving timer interrupts
  >> after a very short while.  Has anyone seen this?

I tried quickly on a 4-way rx5670.  It looks fine (so far):

 $ uname -r
 2.5.67
 $ cat /proc/interrupts |grep timer
 239:     845908     846158     846460     846390          LSAPIC  timer

However, I have been seeing what appears to be deadlocks in the VFS
layer (best guess).  I don't know yet what triggers it and it triggers
at variable rates (sometimes a couple of minutes, sometimes a couple
of hours between occurrences), but perhaps it's related to what you're
seeing.

	--david

