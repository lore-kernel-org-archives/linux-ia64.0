From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 01 Mar 2002 02:32:07 +0000
Subject: Re: [Linux-ia64] VHPT performance
Message-Id: <marc-linux-ia64-105590701905205@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905139@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905139@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 28 Feb 2002 09:06:54 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> David Could you please send me your test program to
  Christian> verify this. Since I haven't fixed the storage in my test
  Christian> prog maybe there are additional page faults.

Well, the copyright is almost longer than the program itself, but here
you go.  It was just a quick hack, so treat with care...  If you do
make enhancements, I'd be interested, though.

	--david

/*
    Copyright (c) 1999-2002 Hewlett-Packard Co.
	Written by David Mosberger-Tang <davidm@hpl.hp.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

The program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.  */

#include <stdio.h>
#include <string.h>

#include <sys/time.h>

#define MAX_DTLB_SIZE	  4096
#define PAGE_SIZE	65536
#define LINE_SIZE	   64
#define LONGS_PER_LINE	(LINE_SIZE/sizeof(long))

#define LOOKUPS_PER_TEST	30000000

static long page[2*MAX_DTLB_SIZE][PAGE_SIZE/sizeof(long)];

long
walk (long count)
{
  long index = 0, i, sum = 0;

  for (i = 0; i < LOOKUPS_PER_TEST; ++i)
    {
      sum += page[index][(index*LONGS_PER_LINE) % (PAGE_SIZE/sizeof(long))];
      ++index;
      if (index >= count)
	index = 0;
    }
  return sum;
}


void
run (const char *label, long (*func)(long), long count)
{
  struct timeval tv_start, tv_stop;
  double delta;
  long result;
  int n;

  for (n = 0; n < 1; ++n)
    {
      gettimeofday(&tv_start, 0);
      result = (*func)(count);
      gettimeofday(&tv_stop, 0);
      delta = ((tv_stop.tv_sec + tv_stop.tv_usec / 1000000.0)
	       - (tv_start.tv_sec + tv_start.tv_usec / 1000000.0));
      if (delta > 0.0)
	printf("%s: %10.5g seconds: %10.5g ns/access (checksum=%lu)\n",
	       label, delta, 1e9 * delta / LOOKUPS_PER_TEST, result);
    }
}

int
main (int argc, char ** argv)
{
  char buf[256];
  int i;

  for (i = 0; i < MAX_DTLB_SIZE; i += 1 + i/100)
    {
      sprintf (buf, "%3u", i);
      run(buf, walk, i);
    }
  return 0;
}

