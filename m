From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Mon, 16 Aug 2004 22:23:28 +0000
Subject: Re: [PATCH] fix generic build when CONFIG_SMP=n
Message-Id: <20040816152328.229b9c93.rddunlap@osdl.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Multipart=_Mon__16_Aug_2004_15_23_28_-0700_rmpqDny_QZq4Sov8"
List-Id: <linux-ia64.vger.kernel.org>
References: <200408131559.59229.jbarnes@engr.sgi.com>
In-Reply-To: <200408131559.59229.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Mon__16_Aug_2004_15_23_28_-0700_rmpqDny_QZq4Sov8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Sun, 15 Aug 2004 21:29:37 -0600 dann frazier wrote:

| On Fri, Aug 13, 2004 at 03:59:59PM -0700, Jesse Barnes wrote:
| > This patch fixes the issues I saw with CONFIG_SMP=n when building a generic 
| > kernel with CONFIG_NUMA=y and CONFIG_DISCONTIGMEM=y.  It's still pretty 
| > rough, but I'd appreciate comments and testing on other platforms.  The 
| > per-cpu fixes are still pretty ugly--I'm sure I'm missing something that 
| > would make abstracting out per_cpu(cpu_info, cpu).node_data = 
| > mem_data[node].node_data much nicer looking.
| > 
| > Fixing the build of generic kernels w/o CONFIG_NUMA or CONFIG_DISCONTIGMEM is 
| > left as an exercise for the reader. :)
| 
| Here's the results of some 2.6.8 boot testing:
| 
| -----------------------------------------------------------------------------
|  generic-no-smp-2    generic_defconfig                                     
|     patch?                delta               machine           results    
| -----------------------------------------------------------------------------
|      No               ITANIUM=y                HP i2000            OK
| -----------------------------------------------------------------------------
|      Yes              ITANIUM=y                HP i2000            OK
| -----------------------------------------------------------------------------
|      Yes              ITANIUM=y                   N/A         build fails [1]
|                       SMP=n
| -----------------------------------------------------------------------------
|      Yes              ITANIUM=y                   N/A         build fails [2]
|                       SMP=n
|                       CYCLONE=n
| -----------------------------------------------------------------------------
|      Yes              ITANIUM=y                   N/A              OK
|                       SMP=n
|                       CYCLONE=n                HP i2000
|                       SERIAL_SGI_L1_CONSOLE=n
| -----------------------------------------------------------------------------
|      Yes                                       HP rx2600           OK
| -----------------------------------------------------------------------------
|      Yes              SMP=n                    HP rx2600           OK
|                       CYCLONE=n
|                       SERIAL_SGI_L1_CONSOLE=n
| [1]
is fixed by the attached patch...

| [2]

[2] is fixed by
http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.8.1/2.6.8.1-mm1/broken-out/fix-sn_console-for-config_smp=n.patch


--
~Randy

--Multipart=_Mon__16_Aug_2004_15_23_28_-0700_rmpqDny_QZq4Sov8
Content-Type: application/octet-stream;
 name="ia64_cyclone_nosmp.patch"
Content-Disposition: attachment;
 filename="ia64_cyclone_nosmp.patch"
Content-Transfer-Encoding: base64

CmZpeCBpYTY0IGN5Y2xvbmUgYnVpbGQgZXJyb3JzCgpTaWduZWQtb2ZmLWJ5OiBSYW5keSBEdW5s
YXAgPHJkZHVubGFwQG9zZGwub3JnPgoKZGlmZnN0YXQ6PQogYXJjaC9pYTY0L2tlcm5lbC9jeWNs
b25lLmMgfCAgICAzICsrKwogMSBmaWxlcyBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKykKCmRpZmYg
LU5hdXJwIC4vYXJjaC9pYTY0L2tlcm5lbC9jeWNsb25lLmN+aWE2NF9ub19zbXAgLi9hcmNoL2lh
NjQva2VybmVsL2N5Y2xvbmUuYwotLS0gLi9hcmNoL2lhNjQva2VybmVsL2N5Y2xvbmUuY35pYTY0
X25vX3NtcAlNb24gQXVnIDE2IDE0OjEzOjUyIDIwMDQKKysrIC4vYXJjaC9pYTY0L2tlcm5lbC9j
eWNsb25lLmMJTW9uIEF1ZyAxNiAxNDowNjoyNiAyMDA0CkBAIC0xLDcgKzEsMTAgQEAKKyNpbmNs
dWRlIDxsaW51eC9pbml0Lmg+CiAjaW5jbHVkZSA8bGludXgvc21wLmg+CiAjaW5jbHVkZSA8bGlu
dXgvdGltZS5oPgogI2luY2x1ZGUgPGxpbnV4L2Vycm5vLmg+CiAKKyNpbmNsdWRlIDxhc20vaW8u
aD4KKwogLyogSUJNIFN1bW1pdCAoRVhBKSBDeWNsb25lIGNvdW50ZXIgY29kZSovCiAjZGVmaW5l
IENZQ0xPTkVfQ0JBUl9BRERSIDB4RkVCMDBDRDAKICNkZWZpbmUgQ1lDTE9ORV9QTUNDX09GRlNF
VCAweDUxQTAK

--Multipart=_Mon__16_Aug_2004_15_23_28_-0700_rmpqDny_QZq4Sov8--
