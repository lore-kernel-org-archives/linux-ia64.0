From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Wed, 19 Nov 2003 10:40:20 +0000
Subject: MAX_CACHE_ERRORS, MAX_TLB_ERRORS, MAX_BUS_ERRORS
Message-Id: <marc-linux-ia64-106923854724282@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I can see the following defines in sal.h:

#define MAX_CACHE_ERRORS	6
#define MAX_TLB_ERRORS		6
#define MAX_BUS_ERRORS		1

As far as I can understand the spec., we've got a 4 bit
wide field as a counter for each of them, i.e. we may have
0 ... 15 of each errors. Does the spec. state explicitly
somewhere how the number of these errors are limited ?
What about the REG and the MS errors ?
Thanks.

Zoltan Menyhart
