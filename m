From: "Skinner, Rod" <rod.skinner@intel.com>
Date: Mon, 23 Jul 2001 10:40:56 +0000
Subject: [Linux-ia64] -relax text1
Message-Id: <marc-linux-ia64-105590693005860@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The -relax option on ld handles ip relative branches in the text segment
that are longer than the 20-bit instruction field will hold.  I have been
trying to figure out a way to have two segments handled in the same way ...
say text and text1.  I have tried playing with the default ld script without
much luck.  Is there a way to set up ld to handle long branches in two
separate text segments?

thanks
rod 


