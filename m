From: dann frazier <dannf@hp.com>
Date: Thu, 27 Oct 2005 14:32:55 +0000
Subject: RE: CONFIG_SGI_SN_XP=m doesn't boot on zx1
Message-Id: <1130423575.7335.189.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <1130359742.7335.115.camel@localhost>
In-Reply-To: <1130359742.7335.115.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-10-26 at 14:19 -0700, Luck, Tony wrote:
> >Setting CONFIG_SGI_SN_XP=m (which forces CONFIG_GENERIC_ALLOCATOR=y and
> >CONFIG_IA64_UNCACHED_ALLOCATOR=y) causes my rx2600 to MCA when booting
> >the latest aegl git tree, before any messages are printed to the screen.
> >Complete .config file attached.  
> >
> >I'm going to disable this module in the Debian kernel tree for now.
> 
> I think that this is fixed in the "test" branch of my GIT tree ... if
> you have time could you give that a try?

Yes, that does seem to work (well, until it tries to init its initramfs,
but that's a different problem), thanks!



