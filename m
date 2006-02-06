From: Sam Ravnborg <sam@ravnborg.org>
Date: Mon, 06 Feb 2006 19:10:43 +0000
Subject: Re: [patch 2.6.16-rc2] Correct CPPFLAGS in arch/ia64/sn
Message-Id: <20060206191042.GA12979@mars.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <6588.1139189682@kao2.melbourne.sgi.com>
In-Reply-To: <6588.1139189682@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 06, 2006 at 12:34:42PM +1100, Keith Owens wrote:
> When building a specific object or subdirectory, kbuild does not do a
> recursive make, instead it starts with the Makefile for the file or
> directory.  Therefore flags which are set in higher level Makefiles are
> missing.  The only way to make kbuild work when building a specific
> object/directory is not to rely on flag propagation, instead the flags
> must be set in each Makefile.  IA64 SN directories have this problem.
> 
> Signed-off-by: Keith Owens <kaos@sgi.com>
Acked-by: Sam Ravnborg <sam@ravnborg.org>

There is no other way to achieve this today.
sn is specific since CPPFLAGS is only used in ia64/sn and below.

	Sam
