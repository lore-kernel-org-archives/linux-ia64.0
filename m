From: Stephen Mulcahy <stephen.mulcahy@hp.com>
Date: Wed, 14 May 2003 16:38:36 +0000
Subject: RE: [Linux-ia64] keyboard problems with post 2.4.17 kernels on
Message-Id: <marc-linux-ia64-105590723705798@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705796@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705796@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

PS2, sorry for the omission. I have tried unplugging and replugging to
no avail. It seems to be something systematic that changed since
2.4.17 because I didn't experience any problems up to then (I haven't
been tracking kernel updates in a while .. serves me right :-)

-stephen

On Wed, 14 May 2003, Luck, Tony wrote:

LT> > I've been having difficulty compiling a kernel that provides a working
LT> > keyboard from sources newer than 2.4.17 - is this a known problem
LT> > (google sheds no light on things)? I can't see anything in dmesg to
LT> > suggest an error but as soon as elilo hands loads the kernel, I lose
LT> > the ability to input anything through the keyboard.
LT> >
LT> > This is with vanilla kernel sources (2.4.18, 2.4.19 and 2.4.20) +
LT> > official ia64 patches and with debian kernel sources.
LT>
LT> USB or PS/2 keyboard?
LT>
LT> On PS/2 ... I've had problems on various versions of Linux on my
LT> BigSur where the keyboard doesn't work.  Unplugging and re-plugging
LT> the keyboard (and then typing a few characters) always seems to
LT> unjam it.
LT>
LT> On USB ... I often fail to get all the config options right to enable
LT> the keyboard ... but that's a personal problem.
LT>
LT> -Tony
LT>

-- 
   Stephen Mulcahy, Software Engineer, Mission Critical & Proactive Services,
     HP Customer Support R&D, HP, Ballybrit Business Park, Galway, Ireland.

The contents of this message and any attachments to it are confidential and may
be legally privileged. If you have received this message in error you should
delete it from your system immediately and advise the sender.

To any recipient of this message within HP, unless otherwise stated, you should
consider this message and attachments as "HP CONFIDENTIAL".


