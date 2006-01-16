From: Prarit Bhargava <prarit@sgi.com>
Date: Mon, 16 Jan 2006 19:27:01 +0000
Subject: [RFC]: Standardizing the SAL calls in arch/ia64
Message-Id: <43CBF385.60205@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[RFC]: Standardizing the SAL calls in arch/ia64

Hello all,

I recently did a small amount of work on a SAL call in the patch

http://www.gelato.unsw.edu.au/archives/linux-ia64/0512/16309.html

While coding for this patch I noticed several minor-medium issues with
the SAL calls.

1) Some SAL calls do not properly return a SAL status.
2) Many of the SAL calls do not properly set ia64_sal_retval values to 0.
3) Callers of the SAL calls are not doing error checking.
4) The SAL status returns are not #define'd anywhere.
5) Several "dead" calls remaining in the code base.
6) Lots of Documentation/CodingStyle fix ups needed...

After looking at the SAL calls in arch/ia64, I suggest that we standardize
the SAL calls by using:

#define SAL_CALL_RETURN(isrv) do {      \
         return isrv.status;             \
} while (0)

b) return status and isrv.v0,

#define SAL_CALL_RETURN_V0(isrv, value) do {    \
         *value = isrv.v0;                       \
         return isrv.status;                     \
} while (0)

#define SAL_RETVAL_DECLARE(isrv) do {                   \
         struct ia64_sal_retval isrv = { 0,0,0,0 };      \
}while (0)

Admittedly, there are two or three cases which do not fit this model, but
this goes a long way to cleaning up the code.

For example,

static inline u64
ia64_sal_get_state_info_size (u64 sal_info_type)
{
         struct ia64_sal_retval isrv;
         SAL_CALL_REENTRANT(isrv, SAL_GET_STATE_INFO_SIZE, sal_info_type,
			   0, 0, 0, 0, 0, 0);
         if (isrv.status)
                 return 0;
         return isrv.v0;
}

would become

static s64
ia64_sal_get_state_info_size (u64 sal_info_type, u64 *result)
{
         SAL_RETVAL_DECLARE(isrv);
         SAL_CALL_REENTRANT(isrv, SAL_GET_STATE_INFO_SIZE, sal_info_type,
			   0, 0, 0, 0, 0, 0);
         SAL_CALL_RETURN_V0(isrv,result);
}

Thoughts, concerns?

P.
