From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 02 Apr 2003 06:20:19 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] sal calls w/o taking sal_lock
Message-Id: <marc-linux-ia64-105590723705383@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705378@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705378@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2 Apr 2003 00:09:53 -0600 , 
"Van Maren, Kevin" <kevin.vanmaren@unisys.com> wrote:
>> I do not understand why you renamed the variables.  The SAL code is
>> enclosed in do { } while();  All variables within {} are 
>> local, they do not need unique names.
>
>What happens to this:
>
>#define foo(arg) do { int flag; arg = flag; } while (0)
>
>If I do this:
>
>	foo(flag);
>
>Answer:
>
>	do { int flag; flag = flag; } while (0);
>
>Does his change make more sense now?

You get around that by using __flags in the macro.  You do not need
__ia64_sc_flags in SAL_CALL() and a different __ia64_scn_flags in
SAL_CALL_NOLOCK().  The old SAL_CALL() code has been there since IA64
was released and has never had any problems with name scopes.


