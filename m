From: Khalid Aziz <khalid@lyra.fc.hp.com>
Date: Thu, 25 Jan 2001 16:44:58 +0000
Subject: Re: [Linux-ia64] Announce: IA-64 cross compiler on IA-32 available
Message-Id: <marc-linux-ia64-105590693005103@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005089@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005089@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> Did the applications you built actually run? I compiled hello world
> but it wouldn't run on TurboLinux release 000828 English Frontier (Burning
> Man) because the cross compiler linked it with /lib/ld-linux-ia64.so.2
> (which points to ld-2.2.so), but the os has /lib/ld-linux-ia64.so.1
> (points to ld-2.1.3.so, which is in glibc-2.1.3).
> 
> Which os issue are you using? Since most machines out there are
> still glibc-2.1.3, could you perhaps recompile for that (or make your
> src tree and build instructions available and I'll do it?)
> 
> thanks
> 
> -- Mark Goodwin
> SGI Engineering.
> 

I apologize. I should have mentioned that the libraries in that build
are from TurboLinux 1123 release. I can make the sources and build
instructions available. Instructions are just in my head right now. I
will write them down and send an email when I have put them up on a web
page.

---
Khalid

==================================
Khalid Aziz                             Linux Development Laboratory
(970)898-9214                                        Hewlett-Packard
khalid@fc.hp.com                                    Fort Collins, CO

