From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 28 Mar 2008 09:59:15 +0000
Subject: [02/17][PATCH] Implement smp_call_function_mask for ia64
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7EFE@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C890BA.61BFE1BB"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C890BA.61BFE1BB
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 9118d25b4e98bef3a62429f8c150e8d429396c40 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 12:58:02 +0800
Subject: [PATCH] Implement smp_call_function_mask for ia64

This function provides more flexible interface for smp
infrastructure.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kernel/smp.c |   84
+++++++++++++++++++++++++++++++++++++----------
 include/linux/smp.h    |    3 ++
 2 files changed, 69 insertions(+), 18 deletions(-)

diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 4e446aa..5bb241f 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -213,6 +213,19 @@ send_IPI_allbutself (int op)
  * Called with preemption disabled.
  */
 static inline void
+send_IPI_mask(cpumask_t mask, int op)
+{
+	unsigned int cpu;
+
+	for_each_cpu_mask(cpu, mask) {
+			send_IPI_single(cpu, op);
+	}
+}
+
+/*
+ * Called with preemption disabled.
+ */
+static inline void
 send_IPI_all (int op)
 {
 	int i;
@@ -401,33 +414,36 @@ smp_call_function_single (int cpuid, void (*func)
(void *info), void *info, int
 }
 EXPORT_SYMBOL(smp_call_function_single);
=20
-/*
- * this function sends a 'generic call function' IPI to all other CPUs
- * in the system.
- */
-
-/*
- *  [SUMMARY]	Run a function on all other CPUs.
- *  <func>	The function to run. This must be fast and non-blocking.
- *  <info>	An arbitrary pointer to pass to the function.
- *  <nonatomic>	currently unused.
- *  <wait>	If true, wait (atomically) until function has completed
on other CPUs.
- *  [RETURNS]   0 on success, else a negative status code.
+/**
+ * smp_call_function_mask(): Run a function on a set of other CPUs.
+ * <mask>	The set of cpus to run on.  Must not include the current
cpu.
+ * <func> 	The function to run. This must be fast and non-blocking.
+ * <info>	An arbitrary pointer to pass to the function.
+ * <wait>	If true, wait (atomically) until function
+ *		has completed on other CPUs.
  *
- * Does not return until remote CPUs are nearly ready to execute <func>
or are or have
- * executed.
+ * Returns 0 on success, else a negative status code.
+ *
+ * If @wait is true, then returns once @func has returned; otherwise
+ * it returns just before the target cpu calls @func.
  *
  * You must not call this function with disabled interrupts or from a
  * hardware interrupt handler or from a bottom half handler.
  */
-int
-smp_call_function (void (*func) (void *info), void *info, int
nonatomic, int wait)
+int smp_call_function_mask(cpumask_t mask,
+			   void (*func)(void *), void *info,
+			   int wait)
 {
 	struct call_data_struct data;
+	cpumask_t allbutself;
 	int cpus;
=20
 	spin_lock(&call_lock);
-	cpus =3D num_online_cpus() - 1;
+	allbutself =3D cpu_online_map;
+	cpu_clear(smp_processor_id(), allbutself);
+
+	cpus_and(mask, mask, allbutself);
+	cpus =3D cpus_weight(mask);
 	if (!cpus) {
 		spin_unlock(&call_lock);
 		return 0;
@@ -445,7 +461,12 @@ smp_call_function (void (*func) (void *info), void
*info, int nonatomic, int wai
=20
 	call_data =3D &data;
 	mb();	/* ensure store to call_data precedes setting of
IPI_CALL_FUNC */
-	send_IPI_allbutself(IPI_CALL_FUNC);
+
+	/* Send a message to other CPUs */
+	if (cpus_equal(mask, allbutself))
+		send_IPI_allbutself(IPI_CALL_FUNC);
+	else
+		send_IPI_mask(mask, IPI_CALL_FUNC);
=20
 	/* Wait for response */
 	while (atomic_read(&data.started) !=3D cpus)
@@ -458,6 +479,33 @@ smp_call_function (void (*func) (void *info), void
*info, int nonatomic, int wai
=20
 	spin_unlock(&call_lock);
 	return 0;
+
+}
+EXPORT_SYMBOL(smp_call_function_mask);
+
+/*
+ * this function sends a 'generic call function' IPI to all other CPUs
+ * in the system.
+ */
+
+/*
+ *  [SUMMARY]	Run a function on all other CPUs.
+ *  <func>	The function to run. This must be fast and non-blocking.
+ *  <info>	An arbitrary pointer to pass to the function.
+ *  <nonatomic>	currently unused.
+ *  <wait>	If true, wait (atomically) until function has completed
on other CPUs.
+ *  [RETURNS]   0 on success, else a negative status code.
+ *
+ * Does not return until remote CPUs are nearly ready to execute <func>
or are or have
+ * executed.
+ *
+ * You must not call this function with disabled interrupts or from a
+ * hardware interrupt handler or from a bottom half handler.
+ */
+int
+smp_call_function (void (*func) (void *info), void *info, int
nonatomic, int wait)
+{
+	return smp_call_function_mask(cpu_online_map, func, info, wait);
 }
 EXPORT_SYMBOL(smp_call_function);
=20
diff --git a/include/linux/smp.h b/include/linux/smp.h
index 55232cc..b71820b 100644
--- a/include/linux/smp.h
+++ b/include/linux/smp.h
@@ -56,6 +56,9 @@ int smp_call_function(void(*func)(void *info), void
*info, int retry, int wait);
=20
 int smp_call_function_single(int cpuid, void (*func) (void *info), void
*info,
 				int retry, int wait);
+int smp_call_function_mask(cpumask_t mask,
+			   void (*func)(void *), void *info,
+			   int wait);
=20
 /*
  * Call a function on all processors
--=20
1.5.2

------_=_NextPart_001_01C890BA.61BFE1BB
Content-Type: application/octet-stream;
	name="0002-Implement-smp_call_function_mask-for-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0002-Implement-smp_call_function_mask-for-ia64.patch
Content-Disposition: attachment;
	filename="0002-Implement-smp_call_function_mask-for-ia64.patch"

RnJvbSA5MTE4ZDI1YjRlOThiZWYzYTYyNDI5ZjhjMTUwZThkNDI5Mzk2YzQwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMjo1ODowMiArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEltcGxlbWVudCBzbXBfY2FsbF9mdW5jdGlvbl9tYXNrIGZvciBpYTY0CgpUaGlzIGZ1bmN0aW9u
IHByb3ZpZGVzIG1vcmUgZmxleGlibGUgaW50ZXJmYWNlIGZvciBzbXAKaW5mcmFzdHJ1Y3R1cmUu
ClNpZ25lZC1vZmYtYnk6IFhpYW50YW8gWmhhbmcgPHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgot
LS0KIGFyY2gvaWE2NC9rZXJuZWwvc21wLmMgfCAgIDg0ICsrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKystLS0tLS0tLS0tCiBpbmNsdWRlL2xpbnV4L3NtcC5oICAgIHwgICAgMyAr
KwogMiBmaWxlcyBjaGFuZ2VkLCA2OSBpbnNlcnRpb25zKCspLCAxOCBkZWxldGlvbnMoLSkKCmRp
ZmYgLS1naXQgYS9hcmNoL2lhNjQva2VybmVsL3NtcC5jIGIvYXJjaC9pYTY0L2tlcm5lbC9zbXAu
YwppbmRleCA0ZTQ0NmFhLi41YmIyNDFmIDEwMDY0NAotLS0gYS9hcmNoL2lhNjQva2VybmVsL3Nt
cC5jCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvc21wLmMKQEAgLTIxMyw2ICsyMTMsMTkgQEAgc2Vu
ZF9JUElfYWxsYnV0c2VsZiAoaW50IG9wKQogICogQ2FsbGVkIHdpdGggcHJlZW1wdGlvbiBkaXNh
YmxlZC4KICAqLwogc3RhdGljIGlubGluZSB2b2lkCitzZW5kX0lQSV9tYXNrKGNwdW1hc2tfdCBt
YXNrLCBpbnQgb3ApCit7CisJdW5zaWduZWQgaW50IGNwdTsKKworCWZvcl9lYWNoX2NwdV9tYXNr
KGNwdSwgbWFzaykgeworCQkJc2VuZF9JUElfc2luZ2xlKGNwdSwgb3ApOworCX0KK30KKworLyoK
KyAqIENhbGxlZCB3aXRoIHByZWVtcHRpb24gZGlzYWJsZWQuCisgKi8KK3N0YXRpYyBpbmxpbmUg
dm9pZAogc2VuZF9JUElfYWxsIChpbnQgb3ApCiB7CiAJaW50IGk7CkBAIC00MDEsMzMgKzQxNCwz
NiBAQCBzbXBfY2FsbF9mdW5jdGlvbl9zaW5nbGUgKGludCBjcHVpZCwgdm9pZCAoKmZ1bmMpICh2
b2lkICppbmZvKSwgdm9pZCAqaW5mbywgaW50CiB9CiBFWFBPUlRfU1lNQk9MKHNtcF9jYWxsX2Z1
bmN0aW9uX3NpbmdsZSk7CiAKLS8qCi0gKiB0aGlzIGZ1bmN0aW9uIHNlbmRzIGEgJ2dlbmVyaWMg
Y2FsbCBmdW5jdGlvbicgSVBJIHRvIGFsbCBvdGhlciBDUFVzCi0gKiBpbiB0aGUgc3lzdGVtLgot
ICovCi0KLS8qCi0gKiAgW1NVTU1BUlldCVJ1biBhIGZ1bmN0aW9uIG9uIGFsbCBvdGhlciBDUFVz
LgotICogIDxmdW5jPglUaGUgZnVuY3Rpb24gdG8gcnVuLiBUaGlzIG11c3QgYmUgZmFzdCBhbmQg
bm9uLWJsb2NraW5nLgotICogIDxpbmZvPglBbiBhcmJpdHJhcnkgcG9pbnRlciB0byBwYXNzIHRv
IHRoZSBmdW5jdGlvbi4KLSAqICA8bm9uYXRvbWljPgljdXJyZW50bHkgdW51c2VkLgotICogIDx3
YWl0PglJZiB0cnVlLCB3YWl0IChhdG9taWNhbGx5KSB1bnRpbCBmdW5jdGlvbiBoYXMgY29tcGxl
dGVkIG9uIG90aGVyIENQVXMuCi0gKiAgW1JFVFVSTlNdICAgMCBvbiBzdWNjZXNzLCBlbHNlIGEg
bmVnYXRpdmUgc3RhdHVzIGNvZGUuCisvKioKKyAqIHNtcF9jYWxsX2Z1bmN0aW9uX21hc2soKTog
UnVuIGEgZnVuY3Rpb24gb24gYSBzZXQgb2Ygb3RoZXIgQ1BVcy4KKyAqIDxtYXNrPglUaGUgc2V0
IG9mIGNwdXMgdG8gcnVuIG9uLiAgTXVzdCBub3QgaW5jbHVkZSB0aGUgY3VycmVudCBjcHUuCisg
KiA8ZnVuYz4gCVRoZSBmdW5jdGlvbiB0byBydW4uIFRoaXMgbXVzdCBiZSBmYXN0IGFuZCBub24t
YmxvY2tpbmcuCisgKiA8aW5mbz4JQW4gYXJiaXRyYXJ5IHBvaW50ZXIgdG8gcGFzcyB0byB0aGUg
ZnVuY3Rpb24uCisgKiA8d2FpdD4JSWYgdHJ1ZSwgd2FpdCAoYXRvbWljYWxseSkgdW50aWwgZnVu
Y3Rpb24KKyAqCQloYXMgY29tcGxldGVkIG9uIG90aGVyIENQVXMuCiAgKgotICogRG9lcyBub3Qg
cmV0dXJuIHVudGlsIHJlbW90ZSBDUFVzIGFyZSBuZWFybHkgcmVhZHkgdG8gZXhlY3V0ZSA8ZnVu
Yz4gb3IgYXJlIG9yIGhhdmUKLSAqIGV4ZWN1dGVkLgorICogUmV0dXJucyAwIG9uIHN1Y2Nlc3Ms
IGVsc2UgYSBuZWdhdGl2ZSBzdGF0dXMgY29kZS4KKyAqCisgKiBJZiBAd2FpdCBpcyB0cnVlLCB0
aGVuIHJldHVybnMgb25jZSBAZnVuYyBoYXMgcmV0dXJuZWQ7IG90aGVyd2lzZQorICogaXQgcmV0
dXJucyBqdXN0IGJlZm9yZSB0aGUgdGFyZ2V0IGNwdSBjYWxscyBAZnVuYy4KICAqCiAgKiBZb3Ug
bXVzdCBub3QgY2FsbCB0aGlzIGZ1bmN0aW9uIHdpdGggZGlzYWJsZWQgaW50ZXJydXB0cyBvciBm
cm9tIGEKICAqIGhhcmR3YXJlIGludGVycnVwdCBoYW5kbGVyIG9yIGZyb20gYSBib3R0b20gaGFs
ZiBoYW5kbGVyLgogICovCi1pbnQKLXNtcF9jYWxsX2Z1bmN0aW9uICh2b2lkICgqZnVuYykgKHZv
aWQgKmluZm8pLCB2b2lkICppbmZvLCBpbnQgbm9uYXRvbWljLCBpbnQgd2FpdCkKK2ludCBzbXBf
Y2FsbF9mdW5jdGlvbl9tYXNrKGNwdW1hc2tfdCBtYXNrLAorCQkJICAgdm9pZCAoKmZ1bmMpKHZv
aWQgKiksIHZvaWQgKmluZm8sCisJCQkgICBpbnQgd2FpdCkKIHsKIAlzdHJ1Y3QgY2FsbF9kYXRh
X3N0cnVjdCBkYXRhOworCWNwdW1hc2tfdCBhbGxidXRzZWxmOwogCWludCBjcHVzOwogCiAJc3Bp
bl9sb2NrKCZjYWxsX2xvY2spOwotCWNwdXMgPSBudW1fb25saW5lX2NwdXMoKSAtIDE7CisJYWxs
YnV0c2VsZiA9IGNwdV9vbmxpbmVfbWFwOworCWNwdV9jbGVhcihzbXBfcHJvY2Vzc29yX2lkKCks
IGFsbGJ1dHNlbGYpOworCisJY3B1c19hbmQobWFzaywgbWFzaywgYWxsYnV0c2VsZik7CisJY3B1
cyA9IGNwdXNfd2VpZ2h0KG1hc2spOwogCWlmICghY3B1cykgewogCQlzcGluX3VubG9jaygmY2Fs
bF9sb2NrKTsKIAkJcmV0dXJuIDA7CkBAIC00NDUsNyArNDYxLDEyIEBAIHNtcF9jYWxsX2Z1bmN0
aW9uICh2b2lkICgqZnVuYykgKHZvaWQgKmluZm8pLCB2b2lkICppbmZvLCBpbnQgbm9uYXRvbWlj
LCBpbnQgd2FpCiAKIAljYWxsX2RhdGEgPSAmZGF0YTsKIAltYigpOwkvKiBlbnN1cmUgc3RvcmUg
dG8gY2FsbF9kYXRhIHByZWNlZGVzIHNldHRpbmcgb2YgSVBJX0NBTExfRlVOQyAqLwotCXNlbmRf
SVBJX2FsbGJ1dHNlbGYoSVBJX0NBTExfRlVOQyk7CisKKwkvKiBTZW5kIGEgbWVzc2FnZSB0byBv
dGhlciBDUFVzICovCisJaWYgKGNwdXNfZXF1YWwobWFzaywgYWxsYnV0c2VsZikpCisJCXNlbmRf
SVBJX2FsbGJ1dHNlbGYoSVBJX0NBTExfRlVOQyk7CisJZWxzZQorCQlzZW5kX0lQSV9tYXNrKG1h
c2ssIElQSV9DQUxMX0ZVTkMpOwogCiAJLyogV2FpdCBmb3IgcmVzcG9uc2UgKi8KIAl3aGlsZSAo
YXRvbWljX3JlYWQoJmRhdGEuc3RhcnRlZCkgIT0gY3B1cykKQEAgLTQ1OCw2ICs0NzksMzMgQEAg
c21wX2NhbGxfZnVuY3Rpb24gKHZvaWQgKCpmdW5jKSAodm9pZCAqaW5mbyksIHZvaWQgKmluZm8s
IGludCBub25hdG9taWMsIGludCB3YWkKIAogCXNwaW5fdW5sb2NrKCZjYWxsX2xvY2spOwogCXJl
dHVybiAwOworCit9CitFWFBPUlRfU1lNQk9MKHNtcF9jYWxsX2Z1bmN0aW9uX21hc2spOworCisv
KgorICogdGhpcyBmdW5jdGlvbiBzZW5kcyBhICdnZW5lcmljIGNhbGwgZnVuY3Rpb24nIElQSSB0
byBhbGwgb3RoZXIgQ1BVcworICogaW4gdGhlIHN5c3RlbS4KKyAqLworCisvKgorICogIFtTVU1N
QVJZXQlSdW4gYSBmdW5jdGlvbiBvbiBhbGwgb3RoZXIgQ1BVcy4KKyAqICA8ZnVuYz4JVGhlIGZ1
bmN0aW9uIHRvIHJ1bi4gVGhpcyBtdXN0IGJlIGZhc3QgYW5kIG5vbi1ibG9ja2luZy4KKyAqICA8
aW5mbz4JQW4gYXJiaXRyYXJ5IHBvaW50ZXIgdG8gcGFzcyB0byB0aGUgZnVuY3Rpb24uCisgKiAg
PG5vbmF0b21pYz4JY3VycmVudGx5IHVudXNlZC4KKyAqICA8d2FpdD4JSWYgdHJ1ZSwgd2FpdCAo
YXRvbWljYWxseSkgdW50aWwgZnVuY3Rpb24gaGFzIGNvbXBsZXRlZCBvbiBvdGhlciBDUFVzLgor
ICogIFtSRVRVUk5TXSAgIDAgb24gc3VjY2VzcywgZWxzZSBhIG5lZ2F0aXZlIHN0YXR1cyBjb2Rl
LgorICoKKyAqIERvZXMgbm90IHJldHVybiB1bnRpbCByZW1vdGUgQ1BVcyBhcmUgbmVhcmx5IHJl
YWR5IHRvIGV4ZWN1dGUgPGZ1bmM+IG9yIGFyZSBvciBoYXZlCisgKiBleGVjdXRlZC4KKyAqCisg
KiBZb3UgbXVzdCBub3QgY2FsbCB0aGlzIGZ1bmN0aW9uIHdpdGggZGlzYWJsZWQgaW50ZXJydXB0
cyBvciBmcm9tIGEKKyAqIGhhcmR3YXJlIGludGVycnVwdCBoYW5kbGVyIG9yIGZyb20gYSBib3R0
b20gaGFsZiBoYW5kbGVyLgorICovCitpbnQKK3NtcF9jYWxsX2Z1bmN0aW9uICh2b2lkICgqZnVu
YykgKHZvaWQgKmluZm8pLCB2b2lkICppbmZvLCBpbnQgbm9uYXRvbWljLCBpbnQgd2FpdCkKK3sK
KwlyZXR1cm4gc21wX2NhbGxfZnVuY3Rpb25fbWFzayhjcHVfb25saW5lX21hcCwgZnVuYywgaW5m
bywgd2FpdCk7CiB9CiBFWFBPUlRfU1lNQk9MKHNtcF9jYWxsX2Z1bmN0aW9uKTsKIApkaWZmIC0t
Z2l0IGEvaW5jbHVkZS9saW51eC9zbXAuaCBiL2luY2x1ZGUvbGludXgvc21wLmgKaW5kZXggNTUy
MzJjYy4uYjcxODIwYiAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9zbXAuaAorKysgYi9pbmNs
dWRlL2xpbnV4L3NtcC5oCkBAIC01Niw2ICs1Niw5IEBAIGludCBzbXBfY2FsbF9mdW5jdGlvbih2
b2lkKCpmdW5jKSh2b2lkICppbmZvKSwgdm9pZCAqaW5mbywgaW50IHJldHJ5LCBpbnQgd2FpdCk7
CiAKIGludCBzbXBfY2FsbF9mdW5jdGlvbl9zaW5nbGUoaW50IGNwdWlkLCB2b2lkICgqZnVuYykg
KHZvaWQgKmluZm8pLCB2b2lkICppbmZvLAogCQkJCWludCByZXRyeSwgaW50IHdhaXQpOworaW50
IHNtcF9jYWxsX2Z1bmN0aW9uX21hc2soY3B1bWFza190IG1hc2ssCisJCQkgICB2b2lkICgqZnVu
Yykodm9pZCAqKSwgdm9pZCAqaW5mbywKKwkJCSAgIGludCB3YWl0KTsKIAogLyoKICAqIENhbGwg
YSBmdW5jdGlvbiBvbiBhbGwgcHJvY2Vzc29ycwotLSAKMS41LjIKCg==

------_=_NextPart_001_01C890BA.61BFE1BB--
