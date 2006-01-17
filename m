From: Jes Sorensen <jes@sgi.com>
Date: Tue, 17 Jan 2006 08:11:16 +0000
Subject: Re: [RFC]: Standardizing the SAL calls in arch/ia64
Message-Id: <yq0vewjqnob.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <43CBF385.60205@sgi.com>
In-Reply-To: <43CBF385.60205@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Prarit" = Prarit Bhargava <prarit@sgi.com> writes:

Prarit> After looking at the SAL calls in arch/ia64, I suggest that we
Prarit> standardize the SAL calls by using:

Prarit> #define SAL_CALL_RETURN(isrv) do { \ return isrv.status; \ }
Prarit> while (0)

Prarit> b) return status and isrv.v0,

Prarit> #define SAL_CALL_RETURN_V0(isrv, value) do { \ *value Prarit> isrv.v0; \ return isrv.status; \ } while (0)

Prarit> #define SAL_RETVAL_DECLARE(isrv) do { \ struct ia64_sal_retval
Prarit> isrv = { 0,0,0,0 }; \ }while (0)

Prarit> Thoughts, concerns?

Hi Prarit,

I agree with the principle, the current SAL code is an utter
mess. However, rather than obfuscating the code with a bunch of
macros, I'd prefer to simply stick a guideline at the top of the
relevant files and then change the code to match that. In particular
declaring variables within macros and macros that call 'return' aren't
good for making the code easy to read.

Cheers,
Jes
