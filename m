From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 28 Aug 2003 23:35:49 +0000
Subject: Re: [PATCH] ia64 oprofile support for 2.6.0-test4
Message-Id: <marc-linux-ia64-106211445005733@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106193081107734@msgid-missing>
In-Reply-To: <marc-linux-ia64-106193081107734@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 27 Aug 2003 09:57:52 -0400, Will Cohen <wcohen@redhat.com> said:

  Will> Revised the instruction_pointer to return the canonical ip and
  Will> ia64_do_profile() to adjust the resulting ip value for the
  Will> histogram.

Thanks, I applied the patch now, with the following minor changes:

 - replaced open-coded prof_cpu_mask test with "cpu_isset()" (otherwise
   things don't compile with >64 CPUs)

 - fixed some extra blank lines/whitespace issues

I'll push the updated tree a bit later today.  Once you had a chance
to test it, please let me know if I broke something.

Thanks,

	--david
