From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 09 Oct 2003 00:00:38 +0000
Subject: Re: patch suggestion (was Re: [PATCH] move find_memory())
Message-Id: <marc-linux-ia64-106565782509828@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106565756509670@msgid-missing>
In-Reply-To: <marc-linux-ia64-106565756509670@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 08, 2003 at 04:57:01PM -0700, David Mosberger wrote:
> >>>>> On Wed, 8 Oct 2003 16:20:22 -0700, jbarnes@sgi.com (Jesse Barnes) said:
> 
>   Jesse> Now that the ACPI table parsing stuff has been fixed we can
>   Jesse> move find_memory() back where it belongs--after the SRAT
>   Jesse> table has been parsed.
> 
> Quick suggestion: when you submit patches for 2.6.0, it would be a
> good idea to explain what kind of bug this fixes, so that Linus can
> see easily that it's a bug fix.

Oh sorry.  I'll try to be more descriptive of the fix in the future.

> (Jess, don't worry about this particular patch, I'll update the
> changelog myself.)

Ok, thanks.

Jesse
