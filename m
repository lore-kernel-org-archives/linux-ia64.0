From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 24 Jul 2002 23:59:37 +0000
Subject: RE: [Linux-ia64] new problem with memcpy_mck routines
Message-Id: <marc-linux-ia64-105590701905830@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905782@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905782@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It turns out that the screen corruption that Jesse and Alex saw was due to a
bug in generic console vga code.  The scrup() functions uses memcpy to copy
overlapping memory area.  By definition, memcpy() must not be used for
overlapping memory areas.  This patch changed that to memmove() which
handles overlapping areas gracefully.  This also fixes the same screen
corruption when switching from X server to text mode.

There is nothing wrong with new memcpy function.

--- drivers/char/console.c.orig	Wed Jul 24 14:47:20 2002
+++ drivers/char/console.c	Wed Jul 24 14:47:55 2002
@@ -259,7 +259,7 @@
 		return;
 	d = (unsigned short *) (origin+video_size_row*t);
 	s = (unsigned short *) (origin+video_size_row*(t+nr));
-	scr_memcpyw(d, s, (b-t-nr) * video_size_row);
+	scr_memmovew(d, s, (b-t-nr) * video_size_row);
 	scr_memsetw(d + (b-t-nr) * video_num_columns, video_erase_char,
video_size_row*nr);
 }
 

One other question, who is the maintainer for the console code?  This should
go into the base as it is not ia64 specific and could potentially trigger on
other architectures.

- Ken Chen


-----Original Message-----
From: Jesse Barnes [mailto:jbarnes@sgi.com]
Sent: Friday, July 19, 2002 9:37 AM
To: alex_williamson@hp.com
Cc: IA64 mailinglist; Chen, Kenneth W
Subject: Re: [Linux-ia64] new problem with memcpy_mck routines


I've run into this too on the console of the McKinley SDV machines.  A
Control-L cleans it up, but it's really annoying nonetheless.

Jesse

On Thu, Jul 18, 2002 at 08:56:48PM -0600, Alex Williamson wrote:
> 
>    Using the latest memcpy_mck (20020622 + Ken's 7/10 patch) I'm seeing
> problems with screen corruption on VGA.  Here's the test; on a VGA
> console, start vim (colorized syntax highlighting and all), edit a
> large file (several screens).  Scroll down through the file.  You'll
> notice the screen gets corrupted, appears to be columns down the screen
> that scroll faster than others.  I'm using an HP McKinley system and
> have light switched tested by building w/ the old Itanium routines.
> Other apps like less, nvi, etc... don't seem to trigger this.  Thanks,
> 
> 	Alex

