From: Chris Ahna <christopher.j.ahna@intel.com>
Date: Tue, 14 Aug 2001 08:15:40 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.8)
Message-Id: <marc-linux-ia64-105590698805072@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 14, 2001 at 01:19:43AM -0700, David Mosberger wrote:
> Note that Linus switched to the DRM code needed for XFree86-4.1.  But since
> we don't 460gx have AGP support for this version yet and since most
> folks are presumably still running 4.0.x, I kept the old DRM code
> instead.  I assume this will stay so until someone (Chris?) has had a
> chance up update the 460gx code to 4.1.

I have updated DRM code for 460gx working on my machines and should
have a patch out sometime tomorrow.

Chris

