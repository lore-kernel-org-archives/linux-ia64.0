From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 29 Jan 2003 17:12:05 +0000
Subject: Re: [Linux-ia64] segv with gas using gcc 3.2
Message-Id: <marc-linux-ia64-105590709805769@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805767@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805767@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 29 Jan 2003 09:21:09 -0600, Robert K Gjertsen <gjertsen@us.ibm.com> said:

  Rob> I'm seeing gas yak/segv on some assembly code that we use to
  Rob> avoid pulling extraneous instructions into the instruction
  Rob> cache (avoid debugging code when debugging is turned off).
  Rob> This used to work with gcc 2.96 but now dies with gcc 3.2 when
  Rob> optimizations are turned on (-O or higher). I'm trying to
  Rob> reduce this to a smaller and manageable case and also figure
  Rob> out whether I'm doing something ill-advised given that we are
  Rob> making some assumptions on how the code is ordered in the
  Rob> remote section (works OK on i386 with gcc 3.2).  Just seeing if
  Rob> someone may have some insight on my example below.

Perhaps the block-reordering is causing the problems for you?
Might want to try -fno-reorder-blocks.

A general comment: I'd highly discourage to switch sections within a
procedure.  The problem is that the unwind info will be all wrong
otherwise.

	--david

