From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 28 Oct 2002 01:51:40 +0000
Subject: Re: [Linux-ia64] quick ia64 patch for 2.5.44 (UP only)
Message-Id: <marc-linux-ia64-105590709805269@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805243@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805243@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Kimio" = Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp> writes:


Kimio> I have a same problem on Bigsur since 2.5.39.
Kimio> So the problem caused by another bug.

 Yes, I agree there's another problem here.

Kimio> I've heard a rumor that this patch might fix it, but I haven't
Kimio> test it, yet.

Kimio> http://marc.theaimsgroup.com/?l=linux-kernel&m3371059120183&w=2

This patch is for the sound driver, that I haven't compiled in.  So
it's unlikely to fix my problem.  Although maybe there's a similar
problem somewhere else?

I did *not* have the problem on 2.5.39 or on 2.5.44 UP (it appears to
be an SMP problem that was introduced between 2.5.39 and 2.5.44).
I'm using serial console only.

Peter C

