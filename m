From: "H . J . Lu" <hjl@valinux.com>
Date: Thu, 28 Sep 2000 01:19:20 +0000
Subject: [Linux-ia64] Re: test8+0913 patch on B1 BigSur UP
Message-Id: <marc-linux-ia64-105590678205528@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 27, 2000 at 03:39:47PM -0700, H . J . Lu wrote:
> On Wed, Sep 13, 2000 at 06:50:33PM -0700, David Mosberger wrote:
> > Since the last diff had a few serious problems, including the infamous
> > ACPI bug and an fph problem that caused xmms not to work on UP
> > machine, there is now a new diff available at:
> > 
> >  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/
> > 
> > in file linux-2.4.0-test8-ia64-000913.diff.
> > 
> 
> I couldn't get this kernel to work on my B1 BigSur UP. It hangs at the
> random places when going to run level 1 to 3. BTW, test8+0908+acpi
> works fine.
> 

Update to modutils 2.3.17 fixed it.


-- 
H.J. Lu (hjl@gnu.org)

