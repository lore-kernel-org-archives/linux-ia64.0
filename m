From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 13 Mar 2003 22:46:32 +0000
Subject: [Linux-ia64] Re: ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806090@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806055@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806055@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Mar 2003 09:42:41 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> OTOH, if you do not mind changing unw_access_gr(), I will do
  Keith> it that way and free up r29.

No, I don't mind fixing that.  ".save rp, r0" is the only way to
terminate a call-chain in a "race-free" manner, so it needs to work
anyhow.

	--david

