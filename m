From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 14 Aug 2001 08:51:32 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.8)
Message-Id: <marc-linux-ia64-105590698805073@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 14 Aug 2001 01:19:43 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>that Linus switched to the DRM code needed for XFree86-4.1.  But since
>we don't 460gx have AGP support for this version yet and since most
>folks are presumably still running 4.0.x, I kept the old DRM code
>instead.  I assume this will stay so until someone (Chris?) has had a
>chance up update the 460gx code to 4.1.

If you are going to keep both DRM 4.0 and 4.1, please do it the same
way that Alan Cox did, to reduce the number of solutions to this
"problem".  The -ac kernels have, in drivers/char/Config.in

bool 'Direct Rendering Manager (XFree86 DRI support)' CONFIG_DRM

if [ "$CONFIG_DRM" = "y" ]; then
   bool '  Build drivers for new (XFree 4.1) DRM' CONFIG_DRM_NEW
   if [ "$CONFIG_DRM_NEW" = "y" ]; then
      source drivers/char/drm/Config.in
   else
      define_bool CONFIG_DRM_OLD y
      source drivers/char/drm-4.0/Config.in
   fi
fi

drivers/char/drm-4.0/ is a copy of the previous drivers/char/drm with
CONFIG_DRM_foo replaced by CONFIG_DRM40_foo.


