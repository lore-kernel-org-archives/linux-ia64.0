From: "Gavin Scott" <gavin@allegro.com>
Date: Fri, 15 Nov 2002 00:52:13 +0000
Subject: [Linux-ia64] One little, two little, three little endian...
Message-Id: <marc-linux-ia64-105590709805439@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello list,

I want a big endian version of Linux for IPF.  Just how crazy am I?

I'm working with a group of customers and software developers who are
migrating away from HP's proprietary MPE/iX operating system on the HPe3000
systems that HP announced the discontinuance of one year ago today.  Many of
these people are already using HP-UX to some degree, and most are interested
in the possibility of using Linux in the future.

Of course both MPE/iX and HP-UX are big-endian environments, and many of the
people I talk to would be very interested in having an endian-compatible
Linux that would run on big (i.e. IA-64) HP servers.  For this group, x86
compatibility is probably a non-issue.

I'm interested in any comments that come to mind.  I'm most interested in
just how complex the task would be from a technical point of view, either to
make the system buildable either way, or possibly supporting a per-process
endian bit (which would be cool, but probably a lot more work).

I'm reasonably familiar with the IA-64 architecture and know most of what
there is to know about PA-RISC.

Thanks,

Gavin
--
Gavin Scott
Vice President
Allegro Consultants, Inc.
gavin@allegro.com


