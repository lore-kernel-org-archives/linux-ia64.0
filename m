From: Steve Tynor <tynor@atlanta.twr.com>
Date: Tue, 03 Oct 2000 00:46:18 +0000
Subject: re: [Linux-ia64] Re: gcc bug (2.9-ia64-000216-final)
Message-Id: <marc-linux-ia64-105590678205539@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205538@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bill Nottingham wrote:

| Steve Tynor (tynor@atlanta.twr.com) said: 
| > Can someone verify that this bug is fixed in the latest toolchain?
| 
| Works for me. A quick glance at the code makes me think that building
| with -fno-optimize-sibling-calls will work around it for now.

FWIW: in 2.9-ia64-000216-final, that flag apparently does not yet exist: 

      impromptu:~/tmp/ia64bug> gcc -O2 -fno-optimize-sibling-calls ia64bug.c
      cc1: Unrecognised option `-fno-optimize-sibling-calls'
      impromptu:~/tmp/ia64bug> ./a.out 
      in main 9fffffffffffe960: 11 12
      Segmentation fault (core dumped)
      impromptu:~/tmp/ia64bug> 

Steve

