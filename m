From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 05 Mar 2003 00:45:05 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-021210 misaligned sal error record
Message-Id: <marc-linux-ia64-105590709805968@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805925@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805925@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 05 Mar 2003 11:33:33 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Linus recommends static inline instead of #define unless
  Keith> there is no choice.  static inline does type checking,
  Keith> #define does not.

That's a good principle, but doesn't really apply here.  You do
get type-checking:

#define SAL_LPI_PSI_INFO(l)				\
	sal_log_processor_info_t *_l = (l);

and for this type of work-around-C-limitation helper routine, I think
a capitalized macro actually results in more readable code.  It's a
matter of taste, of course.

	--david

