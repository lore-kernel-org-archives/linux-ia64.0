From: Keith Owens <kaos@sgi.com>
Date: Sat, 01 Nov 2003 08:38:37 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106767595422004@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 1 Nov 2003 07:39:52 +0100 ("CET), 
Matthias Fouquet-Lapar <mfl@sgi.com> wrote:
>> Of course, I agree with a common frame set.
>> In the case of platform premising IPF, I think it is
>> better to regard the Intel's Chipset as the de facto
>> standard.
>
>I think there should be an abstraction layer hiding the underlying
>HW implementation. I think handling for example a memory error 
>by killing the affected user application, should work on any chipset
>and/or CPU architecture (if technically possible).

We already have that interface, it is called a signal.  The kernel code
for handling these events has to be architecture dependent but, once
the data has been gathered and the decision made about which user
process to kill, we just send SEGV.

BTW, your email address includes your full hostname, instead of just
mfl@sgi.com.

