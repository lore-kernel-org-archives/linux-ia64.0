From: Alex Williamson <alex_williamson@hp.com>
Date: Fri, 16 May 2003 19:35:52 +0000
Subject: Re: [Linux-ia64] runtime platform detection in GENERIC kernels
Message-Id: <marc-linux-ia64-105590723705910@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Martin Hicks wrote:
> Here is the next iteration, based on your suggestions.  It also caches
> the result of the first acpi_get_sysname() call, since this really
> shouldn't change while the machine is running.
>

Martin,

   Everything is already in place to make this much easier.
I was thinking something more like this:

#define ia64_platform_is(x) (strcmp(x,platform_name) = 0)

The name is stored in the machvec, so you don't need to cache
it anywhere else.

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab

