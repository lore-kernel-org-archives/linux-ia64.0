From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:34:00 +0000
Subject: [PATCH v4 02/16] dell-smo8800: include uaccess.h
Message-Id: <1471642454-5679-3-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, sparclinux@vger.kernel.org, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, xen-devel@lists.xensource.com, msalter@redhat.com, linux-sh@vger.kernel.org, mpe@ellerman.id.au, x86@kernel.org, fontana@sharpeleven.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, jani.nikula@intel.com, will.deacon@arm.com, rusty@rustcorp.com.au, rostedt@goodmis.org, acme@redhat.com, ak@linux.intel.com, andriy.shevchenko@linux.intel.com, mcb30@ip

RnJvbTogIkx1aXMgUi4gUm9kcmlndWV6IiA8bWNncm9mQGtlcm5lbC5vcmc+CgpzZWN0aW9ucy5o
IGlzIGN1cnJlbnRseSBpbmNsdWRlZCBhbmQgaXQgcHJvdmlkZXMgZGVsbC1zbW84ODAwCndpdGgg
d2hhdCBpdCBuZWVkcywgYW4gdXBjb21pbmcgY2hhbmdlIHdpbGwgZGVjb3VwbGUgdWFjY2Vzcy5o
CmZyb20gc2VjdGlvbnMuaC4gVGhpcyBkcml2ZXIgbmVlZHMgdG8gZXhwbGljaXRseSByZXF1aXJl
IHVhY2Nlc3MuaApiZWZvcmUgdGhpcyBjaGFuZ2UuCgp2MzogbmV3IHRvIHRoaXMgc2VyaWVzIC0t
IG5lZWRlZCBkdWUgdG8gY29sbGF0ZXJhbCBvZiB0aGUgc3BsaXQgb2YKICAgIG9sZCBsaW5rZXIg
dGFibGVzIGZyb20gdGFibGVzLmggaW50byAzIGZpbGVzOiBzZWN0aW9ucy5oLCByYW5nZXMuaAog
ICAgYW5kIHRhYmxlcy5oCgpSZXZpZXdlZC1ieTogUGFsaSBSb2jDoXIgPHBhbGkucm9oYXJAZ21h
aWwuY29tPgpTaWduZWQtb2ZmLWJ5OiBMdWlzIFIuIFJvZHJpZ3VleiA8bWNncm9mQGtlcm5lbC5v
cmc+Ci0tLQogZHJpdmVycy9wbGF0Zm9ybS94ODYvZGVsbC1zbW84ODAwLmMgfCAxICsKIDEgZmls
ZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvcGxhdGZvcm0v
eDg2L2RlbGwtc21vODgwMC5jIGIvZHJpdmVycy9wbGF0Zm9ybS94ODYvZGVsbC1zbW84ODAwLmMK
aW5kZXggMGFlYzRmZDRjNDhlLi4zN2U2NDYwMzRlZjggMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvcGxh
dGZvcm0veDg2L2RlbGwtc21vODgwMC5jCisrKyBiL2RyaXZlcnMvcGxhdGZvcm0veDg2L2RlbGwt
c21vODgwMC5jCkBAIC0yNCw2ICsyNCw3IEBACiAjaW5jbHVkZSA8bGludXgvYWNwaS5oPgogI2lu
Y2x1ZGUgPGxpbnV4L2ludGVycnVwdC5oPgogI2luY2x1ZGUgPGxpbnV4L21pc2NkZXZpY2UuaD4K
KyNpbmNsdWRlIDxsaW51eC91YWNjZXNzLmg+CiAKIHN0cnVjdCBzbW84ODAwX2RldmljZSB7CiAJ
dTMyIGlycTsgICAgICAgICAgICAgICAgICAgICAvKiBhY3BpIGRldmljZSBpcnEgKi8KLS0gCjIu
OS4yCgotLQpUbyB1bnN1YnNjcmliZSBmcm9tIHRoaXMgbGlzdDogc2VuZCB0aGUgbGluZSAidW5z
dWJzY3JpYmUgbGludXgtaWE2NCIgaW4KdGhlIGJvZHkgb2YgYSBtZXNzYWdlIHRvIG1ham9yZG9t
b0B2Z2VyLmtlcm5lbC5vcmcKTW9yZSBtYWpvcmRvbW8gaW5mbyBhdCAgaHR0cDovL3ZnZXIua2Vy
bmVsLm9yZy9tYWpvcmRvbW8taW5mby5odG1s
