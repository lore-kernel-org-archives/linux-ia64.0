From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 08:25:07 +0000
Subject: [02/17][PATCH] Implement smp_call_function_mask for ia64 - V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048240@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89308.BAC1F20B"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EFE@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EFE@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89308.BAC1F20B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 697d50286088e98da5ac8653c80aaa96c81abf87 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 09:50:24 +0800
Subject: [PATCH] KVM:IA64: Implement smp_call_function_mask for ia64

This function provides more flexible interface for smp
infrastructure.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kernel/smp.c |   84
+++++++++++++++++++++++++++++++++++++----------
 include/asm-ia64/smp.h |    3 ++
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
diff --git a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
index 4fa733d..ec5f355 100644
--- a/include/asm-ia64/smp.h
+++ b/include/asm-ia64/smp.h
@@ -38,6 +38,9 @@ ia64_get_lid (void)
 	return lid.f.id << 8 | lid.f.eid;
 }
=20
+extern int smp_call_function_mask(cpumask_t mask, void (*func)(void *),
+				  void *info, int wait);
+
 #define hard_smp_processor_id()		ia64_get_lid()
=20
 #ifdef CONFIG_SMP
--=20
1.5.2

------_=_NextPart_001_01C89308.BAC1F20B
Content-Type: application/octet-stream;
	name="0002-KVM-IA64-Implement-smp_call_function_mask-for-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0002-KVM-IA64-Implement-smp_call_function_mask-for-ia64.patch
Content-Disposition: attachment;
	filename="0002-KVM-IA64-Implement-smp_call_function_mask-for-ia64.patch"

RnJvbSA2OTdkNTAyODYwODhlOThkYTVhYzg2NTNjODBhYWE5NmM4MWFiZjg3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogTW9uLCAzMSBNYXIgMjAwOCAwOTo1MDoyNCArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTpJQTY0OiBJbXBsZW1lbnQgc21wX2NhbGxfZnVuY3Rpb25fbWFzayBmb3IgaWE2NAoKVGhp
cyBmdW5jdGlvbiBwcm92aWRlcyBtb3JlIGZsZXhpYmxlIGludGVyZmFjZSBmb3Igc21wCmluZnJh
c3RydWN0dXJlLgpTaWduZWQtb2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGlu
dGVsLmNvbT4KLS0tCiBhcmNoL2lhNjQva2VybmVsL3NtcC5jIHwgICA4NCArKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrLS0tLS0tLS0tLQogaW5jbHVkZS9hc20taWE2NC9zbXAu
aCB8ICAgIDMgKysKIDIgZmlsZXMgY2hhbmdlZCwgNjkgaW5zZXJ0aW9ucygrKSwgMTggZGVsZXRp
b25zKC0pCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2tlcm5lbC9zbXAuYyBiL2FyY2gvaWE2NC9r
ZXJuZWwvc21wLmMKaW5kZXggNGU0NDZhYS4uNWJiMjQxZiAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0
L2tlcm5lbC9zbXAuYworKysgYi9hcmNoL2lhNjQva2VybmVsL3NtcC5jCkBAIC0yMTMsNiArMjEz
LDE5IEBAIHNlbmRfSVBJX2FsbGJ1dHNlbGYgKGludCBvcCkKICAqIENhbGxlZCB3aXRoIHByZWVt
cHRpb24gZGlzYWJsZWQuCiAgKi8KIHN0YXRpYyBpbmxpbmUgdm9pZAorc2VuZF9JUElfbWFzayhj
cHVtYXNrX3QgbWFzaywgaW50IG9wKQoreworCXVuc2lnbmVkIGludCBjcHU7CisKKwlmb3JfZWFj
aF9jcHVfbWFzayhjcHUsIG1hc2spIHsKKwkJCXNlbmRfSVBJX3NpbmdsZShjcHUsIG9wKTsKKwl9
Cit9CisKKy8qCisgKiBDYWxsZWQgd2l0aCBwcmVlbXB0aW9uIGRpc2FibGVkLgorICovCitzdGF0
aWMgaW5saW5lIHZvaWQKIHNlbmRfSVBJX2FsbCAoaW50IG9wKQogewogCWludCBpOwpAQCAtNDAx
LDMzICs0MTQsMzYgQEAgc21wX2NhbGxfZnVuY3Rpb25fc2luZ2xlIChpbnQgY3B1aWQsIHZvaWQg
KCpmdW5jKSAodm9pZCAqaW5mbyksIHZvaWQgKmluZm8sIGludAogfQogRVhQT1JUX1NZTUJPTChz
bXBfY2FsbF9mdW5jdGlvbl9zaW5nbGUpOwogCi0vKgotICogdGhpcyBmdW5jdGlvbiBzZW5kcyBh
ICdnZW5lcmljIGNhbGwgZnVuY3Rpb24nIElQSSB0byBhbGwgb3RoZXIgQ1BVcwotICogaW4gdGhl
IHN5c3RlbS4KLSAqLwotCi0vKgotICogIFtTVU1NQVJZXQlSdW4gYSBmdW5jdGlvbiBvbiBhbGwg
b3RoZXIgQ1BVcy4KLSAqICA8ZnVuYz4JVGhlIGZ1bmN0aW9uIHRvIHJ1bi4gVGhpcyBtdXN0IGJl
IGZhc3QgYW5kIG5vbi1ibG9ja2luZy4KLSAqICA8aW5mbz4JQW4gYXJiaXRyYXJ5IHBvaW50ZXIg
dG8gcGFzcyB0byB0aGUgZnVuY3Rpb24uCi0gKiAgPG5vbmF0b21pYz4JY3VycmVudGx5IHVudXNl
ZC4KLSAqICA8d2FpdD4JSWYgdHJ1ZSwgd2FpdCAoYXRvbWljYWxseSkgdW50aWwgZnVuY3Rpb24g
aGFzIGNvbXBsZXRlZCBvbiBvdGhlciBDUFVzLgotICogIFtSRVRVUk5TXSAgIDAgb24gc3VjY2Vz
cywgZWxzZSBhIG5lZ2F0aXZlIHN0YXR1cyBjb2RlLgorLyoqCisgKiBzbXBfY2FsbF9mdW5jdGlv
bl9tYXNrKCk6IFJ1biBhIGZ1bmN0aW9uIG9uIGEgc2V0IG9mIG90aGVyIENQVXMuCisgKiA8bWFz
az4JVGhlIHNldCBvZiBjcHVzIHRvIHJ1biBvbi4gIE11c3Qgbm90IGluY2x1ZGUgdGhlIGN1cnJl
bnQgY3B1LgorICogPGZ1bmM+IAlUaGUgZnVuY3Rpb24gdG8gcnVuLiBUaGlzIG11c3QgYmUgZmFz
dCBhbmQgbm9uLWJsb2NraW5nLgorICogPGluZm8+CUFuIGFyYml0cmFyeSBwb2ludGVyIHRvIHBh
c3MgdG8gdGhlIGZ1bmN0aW9uLgorICogPHdhaXQ+CUlmIHRydWUsIHdhaXQgKGF0b21pY2FsbHkp
IHVudGlsIGZ1bmN0aW9uCisgKgkJaGFzIGNvbXBsZXRlZCBvbiBvdGhlciBDUFVzLgogICoKLSAq
IERvZXMgbm90IHJldHVybiB1bnRpbCByZW1vdGUgQ1BVcyBhcmUgbmVhcmx5IHJlYWR5IHRvIGV4
ZWN1dGUgPGZ1bmM+IG9yIGFyZSBvciBoYXZlCi0gKiBleGVjdXRlZC4KKyAqIFJldHVybnMgMCBv
biBzdWNjZXNzLCBlbHNlIGEgbmVnYXRpdmUgc3RhdHVzIGNvZGUuCisgKgorICogSWYgQHdhaXQg
aXMgdHJ1ZSwgdGhlbiByZXR1cm5zIG9uY2UgQGZ1bmMgaGFzIHJldHVybmVkOyBvdGhlcndpc2UK
KyAqIGl0IHJldHVybnMganVzdCBiZWZvcmUgdGhlIHRhcmdldCBjcHUgY2FsbHMgQGZ1bmMuCiAg
KgogICogWW91IG11c3Qgbm90IGNhbGwgdGhpcyBmdW5jdGlvbiB3aXRoIGRpc2FibGVkIGludGVy
cnVwdHMgb3IgZnJvbSBhCiAgKiBoYXJkd2FyZSBpbnRlcnJ1cHQgaGFuZGxlciBvciBmcm9tIGEg
Ym90dG9tIGhhbGYgaGFuZGxlci4KICAqLwotaW50Ci1zbXBfY2FsbF9mdW5jdGlvbiAodm9pZCAo
KmZ1bmMpICh2b2lkICppbmZvKSwgdm9pZCAqaW5mbywgaW50IG5vbmF0b21pYywgaW50IHdhaXQp
CitpbnQgc21wX2NhbGxfZnVuY3Rpb25fbWFzayhjcHVtYXNrX3QgbWFzaywKKwkJCSAgIHZvaWQg
KCpmdW5jKSh2b2lkICopLCB2b2lkICppbmZvLAorCQkJICAgaW50IHdhaXQpCiB7CiAJc3RydWN0
IGNhbGxfZGF0YV9zdHJ1Y3QgZGF0YTsKKwljcHVtYXNrX3QgYWxsYnV0c2VsZjsKIAlpbnQgY3B1
czsKIAogCXNwaW5fbG9jaygmY2FsbF9sb2NrKTsKLQljcHVzID0gbnVtX29ubGluZV9jcHVzKCkg
LSAxOworCWFsbGJ1dHNlbGYgPSBjcHVfb25saW5lX21hcDsKKwljcHVfY2xlYXIoc21wX3Byb2Nl
c3Nvcl9pZCgpLCBhbGxidXRzZWxmKTsKKworCWNwdXNfYW5kKG1hc2ssIG1hc2ssIGFsbGJ1dHNl
bGYpOworCWNwdXMgPSBjcHVzX3dlaWdodChtYXNrKTsKIAlpZiAoIWNwdXMpIHsKIAkJc3Bpbl91
bmxvY2soJmNhbGxfbG9jayk7CiAJCXJldHVybiAwOwpAQCAtNDQ1LDcgKzQ2MSwxMiBAQCBzbXBf
Y2FsbF9mdW5jdGlvbiAodm9pZCAoKmZ1bmMpICh2b2lkICppbmZvKSwgdm9pZCAqaW5mbywgaW50
IG5vbmF0b21pYywgaW50IHdhaQogCiAJY2FsbF9kYXRhID0gJmRhdGE7CiAJbWIoKTsJLyogZW5z
dXJlIHN0b3JlIHRvIGNhbGxfZGF0YSBwcmVjZWRlcyBzZXR0aW5nIG9mIElQSV9DQUxMX0ZVTkMg
Ki8KLQlzZW5kX0lQSV9hbGxidXRzZWxmKElQSV9DQUxMX0ZVTkMpOworCisJLyogU2VuZCBhIG1l
c3NhZ2UgdG8gb3RoZXIgQ1BVcyAqLworCWlmIChjcHVzX2VxdWFsKG1hc2ssIGFsbGJ1dHNlbGYp
KQorCQlzZW5kX0lQSV9hbGxidXRzZWxmKElQSV9DQUxMX0ZVTkMpOworCWVsc2UKKwkJc2VuZF9J
UElfbWFzayhtYXNrLCBJUElfQ0FMTF9GVU5DKTsKIAogCS8qIFdhaXQgZm9yIHJlc3BvbnNlICov
CiAJd2hpbGUgKGF0b21pY19yZWFkKCZkYXRhLnN0YXJ0ZWQpICE9IGNwdXMpCkBAIC00NTgsNiAr
NDc5LDMzIEBAIHNtcF9jYWxsX2Z1bmN0aW9uICh2b2lkICgqZnVuYykgKHZvaWQgKmluZm8pLCB2
b2lkICppbmZvLCBpbnQgbm9uYXRvbWljLCBpbnQgd2FpCiAKIAlzcGluX3VubG9jaygmY2FsbF9s
b2NrKTsKIAlyZXR1cm4gMDsKKworfQorRVhQT1JUX1NZTUJPTChzbXBfY2FsbF9mdW5jdGlvbl9t
YXNrKTsKKworLyoKKyAqIHRoaXMgZnVuY3Rpb24gc2VuZHMgYSAnZ2VuZXJpYyBjYWxsIGZ1bmN0
aW9uJyBJUEkgdG8gYWxsIG90aGVyIENQVXMKKyAqIGluIHRoZSBzeXN0ZW0uCisgKi8KKworLyoK
KyAqICBbU1VNTUFSWV0JUnVuIGEgZnVuY3Rpb24gb24gYWxsIG90aGVyIENQVXMuCisgKiAgPGZ1
bmM+CVRoZSBmdW5jdGlvbiB0byBydW4uIFRoaXMgbXVzdCBiZSBmYXN0IGFuZCBub24tYmxvY2tp
bmcuCisgKiAgPGluZm8+CUFuIGFyYml0cmFyeSBwb2ludGVyIHRvIHBhc3MgdG8gdGhlIGZ1bmN0
aW9uLgorICogIDxub25hdG9taWM+CWN1cnJlbnRseSB1bnVzZWQuCisgKiAgPHdhaXQ+CUlmIHRy
dWUsIHdhaXQgKGF0b21pY2FsbHkpIHVudGlsIGZ1bmN0aW9uIGhhcyBjb21wbGV0ZWQgb24gb3Ro
ZXIgQ1BVcy4KKyAqICBbUkVUVVJOU10gICAwIG9uIHN1Y2Nlc3MsIGVsc2UgYSBuZWdhdGl2ZSBz
dGF0dXMgY29kZS4KKyAqCisgKiBEb2VzIG5vdCByZXR1cm4gdW50aWwgcmVtb3RlIENQVXMgYXJl
IG5lYXJseSByZWFkeSB0byBleGVjdXRlIDxmdW5jPiBvciBhcmUgb3IgaGF2ZQorICogZXhlY3V0
ZWQuCisgKgorICogWW91IG11c3Qgbm90IGNhbGwgdGhpcyBmdW5jdGlvbiB3aXRoIGRpc2FibGVk
IGludGVycnVwdHMgb3IgZnJvbSBhCisgKiBoYXJkd2FyZSBpbnRlcnJ1cHQgaGFuZGxlciBvciBm
cm9tIGEgYm90dG9tIGhhbGYgaGFuZGxlci4KKyAqLworaW50CitzbXBfY2FsbF9mdW5jdGlvbiAo
dm9pZCAoKmZ1bmMpICh2b2lkICppbmZvKSwgdm9pZCAqaW5mbywgaW50IG5vbmF0b21pYywgaW50
IHdhaXQpCit7CisJcmV0dXJuIHNtcF9jYWxsX2Z1bmN0aW9uX21hc2soY3B1X29ubGluZV9tYXAs
IGZ1bmMsIGluZm8sIHdhaXQpOwogfQogRVhQT1JUX1NZTUJPTChzbXBfY2FsbF9mdW5jdGlvbik7
CiAKZGlmZiAtLWdpdCBhL2luY2x1ZGUvYXNtLWlhNjQvc21wLmggYi9pbmNsdWRlL2FzbS1pYTY0
L3NtcC5oCmluZGV4IDRmYTczM2QuLmVjNWYzNTUgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvYXNtLWlh
NjQvc21wLmgKKysrIGIvaW5jbHVkZS9hc20taWE2NC9zbXAuaApAQCAtMzgsNiArMzgsOSBAQCBp
YTY0X2dldF9saWQgKHZvaWQpCiAJcmV0dXJuIGxpZC5mLmlkIDw8IDggfCBsaWQuZi5laWQ7CiB9
CiAKK2V4dGVybiBpbnQgc21wX2NhbGxfZnVuY3Rpb25fbWFzayhjcHVtYXNrX3QgbWFzaywgdm9p
ZCAoKmZ1bmMpKHZvaWQgKiksCisJCQkJICB2b2lkICppbmZvLCBpbnQgd2FpdCk7CisKICNkZWZp
bmUgaGFyZF9zbXBfcHJvY2Vzc29yX2lkKCkJCWlhNjRfZ2V0X2xpZCgpCiAKICNpZmRlZiBDT05G
SUdfU01QCi0tIAoxLjUuMgoK

------_=_NextPart_001_01C89308.BAC1F20B--
