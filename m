From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 08 May 2003 01:55:17 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705674@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 7 May 2003 18:46:46 -0700, 
Jesse Barnes <jbarnes@sgi.com> wrote:
>On Wed, May 07, 2003 at 06:07:58PM -0700, David Mosberger wrote:
>>   Keith> ksymoops (user space), kdb, kksymoops (kernel).
>> 
>> What about crash-dump tools such as lkcd?  Do they depend on absolute
>> addresses?
>
>We've added an ioctl to the lkcd device so the user level tools can
>get the actual load address of the kernel, but I'm not sure if that's
>part of the community version of lkcd yet.

I send the patch to the lkcd list yesterday, no response yet.


