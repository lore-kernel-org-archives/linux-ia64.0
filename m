From: =?ISO-8859-1?Q?C=EDcero?= <cicero.mota@gmail.com>
Date: Tue, 21 Sep 2004 15:06:07 +0000
Subject: error while executing q-tools-0.1
Message-Id: <ce70c4904092108066397882b@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm having some trouble while executing q-tools-0.1 on debian
(testing/unstable).
After compiling without any problem, I tried to execute q-syscollect
-k -t 10 and the then the following error occurs:

Call-count sampling not supported by 0 PMU; disabling it.
pfm_dispatch_events(): invalid parameters
q-syscollect: child exited with status 1


I checked the code (q-syscollect/q-syscollect.c) and I realised the
the error is in the second call of the pfm_dispatch_events() function

  memset (&oparam, 0, sizeof (oparam));
  ret = pfm_dispatch_events (&iparam, NULL, &oparam, NULL);
  if (ret != PFMLIB_SUCCESS)
    panic ("pfm_dispatch_events(): %s\n", pfm_strerror (ret));

Then, I changed this function as the first call:

  memset (&i2param, 0, sizeof (i2param));
  memset (&oparam, 0, sizeof (oparam));
  ret = pfm_dispatch_events (&iparam, &i2param, &oparam, NULL);
  if (ret != PFMLIB_SUCCESS)
    panic ("pfm_dispatch_events(): %s\n", pfm_strerror (ret));


After that, the error occured in another part of the code

Call-count sampling not supported by 0  PMU; disabling it.
perfmonctl(PFM_WRITE_PMCS) failed (Invalid argument)
q-syscollect: child exited with status 1

This error came from this part of the code

if (perfmonctl (sampling_fd, PFM_WRITE_PMCS, pc, num_pcs) < 0)
    panic ("perfmonctl(PFM_WRITE_PMCS) failed (%s)\n", strerror (errno));


To see the program working I just commented this part and I ran the
program again

debian#./q-syscollect -k -t 10
Call-count sampling not supported by 0 PMU; disabling it.
debian#


it creates the .q directory (this the only situation that it happens)
with only one file

-rw-r--r--    1 root     root       396574 Sep 21 11:22 .kallsyms.crc32.ce65a0a9


I need some help to solve those problems.

debian:/# uname -a
Linux peso 2.6.7 #4 Mon Sep 13 12:46:27 BRT 2004 ia64 unknown


debian:~# dpkg -l | grep pf
ii  libpfm2        2.0-3          IA-64 Performance Monitor (PMU) -- run-time
ii  libpfm3        3.0-3          IA-64 Performance Monitor (PMU) -- run-time
ii  libpfm3-dev    3.0-3          IA-64 Performance Monitor (PMU) -- developme
ii  pfmon          3.0-3          Tool for using the IA-64 Performance Monitor

Thanks!
