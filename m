From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 14 Mar 2003 19:46:50 +0000
Subject: Re: [Linux-ia64] Single bundle loops on Itanium-2 sometimes run slow
Message-Id: <marc-linux-ia64-105590709806113@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806106@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806106@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Mar 2003 12:51:43 -0600 (CST), Jack Steiner <steiner@sgi.com> said:

  Jack> SUMMARY: It appears that if a single bundle misaligned loop is
  Jack> interrupted (timer, etc), when the loop is resumed, it
  Jack> sometimes runs at about 1/3 the normal rate until the loop
  Jack> completes. (I dont mean 1 or a few iterations of the loop!!)

  Jack> 	4000000000000eb0: [MIB] adds r8=1,r32
  Jack> 4000000000000eb6: adds r32=-1,r32 4000000000000ebc:
  Jack> br.cloop.sptk.few 4000000000000eb0 <compute+0x60>;;


  Jack> If "noise" is present, pfmon shows significant lost cycles due
  Jack> to BE_LOST_BW_DUE_TO_FE_BR_ILOCK.  A 15 second sample shows:
  Jack> BE_LOST_BW_DUE_TO_FE_BR_ILOCK = 423 for good run
  Jack> BE_LOST_BW_DUE_TO_FE_BR_ILOCK = 105935651 for noisy run

  Jack> Changing the test so that code is at different addresses
  Jack> effects the likelyhood that noise will occur. Sometimes noise
  Jack> occurs on only a subset of the cpus. Sometimes booting a
  Jack> different kernel changes the likelyhood of seeing noise.

  Jack> Has anyone seen this behavior or have an explanation.

Can you check whether the problem goes away when you turn the loop
into a 2-cycle loop?  My bet is that it will.

	--david

