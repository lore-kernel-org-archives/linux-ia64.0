From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 20 Jul 2002 16:57:00 +0000
Subject: [Linux-ia64] Re: [PATCH]: scheduler complex macros fixes
Message-Id: <marc-linux-ia64-105590701905787@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 19 Jul 2002, Erich Focht wrote:

> The attached patch fixes problems with the "complex" macros in the
> scheduler, as discussed about a week ago with Ingo on this mailing list.

the fix has been in my tree for some time, the latest version, against
2.5.26 is at:

  http://people.redhat.com/mingo/O(1)-scheduler/sched-2.5.26-B7

it has a number of other fixes as well, plus the SCHED_BATCH feature.

	Ingo


