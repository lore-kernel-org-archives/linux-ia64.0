From: Jack Steiner <steiner@sgi.com>
Date: Thu, 17 Feb 2005 17:22:35 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <20050217172234.GA4445@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="7AUc2qLy4jB3hD7Z"
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
To: linux-ia64@vger.kernel.org


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

> 
> Jack Steiner is trying to determine how much more expensive the off-node
> page tables are than on node.  Once we know that, we will know if a
> per-cpu or per-node quicklist type arrangement is truely beneficial or
> if a general use slab without node awareness will be adequate.
> 
> Thanks,
> Robin




Here is the results of a test that measures the benefit of
node-local page tables vs page tables located on a remote
node. This was run on a 64p Altix system using 900MHz/1.5M L3
cpus.

The test is very likely a ~worse-case test. It was contrived to 
maximize the number of TLB misses to page table entries that
are not in the cache of the processor. The test references
memory with a 32M+128 byte stride. The maximizes data cache
hits & minimizes PT cache hits. The page table pages were all 
allocated on 256K boundaries to ensure maximum cache conflicts
for PT references by the VHPT.

Granted, this is a worse case test but I wanted to see
if I could measure the effect. Although this test is atypical of
most apps, it is similar to some very large pointer chasing
applications in the real world.

The test essentially follows a linked list of pointers. When the number of 
entries in the list exceed the size of the TLB, TLB misses occur & 
the processor must make references to the in-memory page table.

      Memory Reference Time (ns/reference) for Pointer Chasing Test

 POINTERS    PT_LOCAL    PT_REMOTE
       1        5.621        5.621
      10        4.226        4.226
      20        3.224        3.224
      30        2.890        2.890
      40       11.418       11.418
      50       11.357       11.357
      60       11.316       11.316
      70       11.287       11.286
      80       11.329       11.302
      90       11.292       12.082
     100       11.272       12.763
     110       11.974       16.075
     120       51.758      132.389  << exceeds TLB capacity here
     130      119.311      382.279
     140      143.726      466.469
     150      158.851      495.946
     160      164.415      515.392
     170      168.822      525.382
     180      168.057      537.250
     190      173.043      536.515
     300      192.804      632.459
     400      204.916      666.561
     500      230.489      693.896
     600      256.716      725.338
     700      286.068      731.309
     800      293.407      740.035
     900      306.296      747.635


I've also attach a graph. It is prettier but may not be friendly
to all mail readers.
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.



--7AUc2qLy4jB3hD7Z
Content-Type: image/png
Content-Disposition: attachment; filename="z.png"
Content-Transfer-Encoding: base64

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
tIbVMAICWsMoWEBAaxBQQEBrPqpy2CMEtCakgDVzwW6IeSC6Zi7YCyEz4PrbJ+92PwhoDYMQ
AQGtQUABAa1BQAEBrWE1jBBCQE/+XTUXzIJUY5wKuH6jGhYj+MCpgKyGyUBAa1gNIwQQ0NdE
CKNgJYCAsTLgo0o1AAGtYSpOQEBruDSHgIDWIKCAgNbQBAsIaA3XhhEQ0BpGwQICWoOAAgJa
w0lJAgJawyhYQEBrGAULCGjNmiosSPVBenWsUAIecwkBrYkr4INKNQABrUFAAQGtWR2E0AS7
IKiA9eoWR0p9MAhoDQIKCGgNAgoIaM1FJyVxXrAxTgXkRjUZCGgNAgoIaA3XhhEQ0BqujCAg
oDUIKEQQ0JV/CKggoDVcG0ZAQGsYBQsIaA0CCghozepUHE2wC8IKyCDEBwi4o9QH417ABgHX
S30w3gVs/v+JJODRTiACWtMH/vLP10QIo2DFtYD/m9+mCZYBH1WqAY4FbJrOwFh9wIrLsznh
r2k6A4MJyLVhvNBUnYEI+N1+t+NWwD4DhhOQixN54a9vfqMJyCV6vdAJ2P9tm7uD2QOjYMGl
gC/v/pq+F/iftvJkIAIKHgUcxh9d7usE9OQfAioOBZwyXzMJ6MlABBS8Cdj0sx+9eC/IgBeW
aoAzAcdjf0Mb3HY5MNIo+FmlGuBLwD7z9QJWXe5DwCtLNcCPgM047O39++syYHevagREwOsZ
3Bta4Pb1t+17gb5umI6AihcBm2YysB/4/r2aXzLgtaUacLWA7fTjS5qENuOE4u1AQOFiAV9Z
qv9R+DP+GH7t/6Y/uodm3Lxp3v3APgO6VBABhWsFfBvSFP6MP+Rv79UgV1LAApUz/RAw4/IM
eBl9+kTAK0s14PI+4Gueopj/NAN+KaMjEFC4fhDSjg8rfcBSE/zJzCEDelsOiICKySh465Y6
EBlyZ69aM+sPIuD1pRrwHAF34uUA5owzVOnLSNdOI+ACCJhzgiq9eHJPGwRcAAFzTsuAdXpJ
fQRcAAFzThQwuY5RdzJT/Qc57d0BPIn66DlvZQFrmuB1yIA5ZzbBCLgKAuacMgipk4ezSr0H
BLSG44ACAlqDgAICWnORgNwvuMh102ROBeR+wRkIaA0CCghoDQIKCGgNAgoIaA0CCghoDQIK
CGgNh2EEBLSFwzAZCGgNAgoIaA0CCghoDQIKCGgNAgoIaA0CCghoDQIKCGgNxwEFBLSF44AZ
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
ixckAAAAAElFTkSuQmCC

--7AUc2qLy4jB3hD7Z--
