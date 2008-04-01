From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:41:27 +0000
Subject: [02/18] [PATCH] IA64: Implement smp_call_function_mask for ia64
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048721@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C893E4.F0D3EB6B"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C893E4.F0D3EB6B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

For considering Jes's performance concern, I kept the old
smp_call_function, and add smp_call_function_mask separately.=20
Xiantao


From fe3c5deac39033fb7651ecce5df3d1dce7dd66f7 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 1 Apr 2008 14:38:21 +0800
Subject: [PATCH] IA64: Implement smp_call_function_mask for ia64

This interface provides more flexible functionalityfor smp
infrastructure.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kernel/smp.c |   82
++++++++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/smp.h |    3 ++
 2 files changed, 85 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 4e446aa..9a9d4c4 100644
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
@@ -401,6 +414,75 @@ smp_call_function_single (int cpuid, void (*func)
(void *info), void *info, int
 }
 EXPORT_SYMBOL(smp_call_function_single);
=20
+/**
+ * smp_call_function_mask(): Run a function on a set of other CPUs.
+ * <mask>	The set of cpus to run on.  Must not include the current
cpu.
+ * <func> 	The function to run. This must be fast and non-blocking.
+ * <info>	An arbitrary pointer to pass to the function.
+ * <wait>	If true, wait (atomically) until function
+ *		has completed on other CPUs.
+ *
+ * Returns 0 on success, else a negative status code.
+ *
+ * If @wait is true, then returns once @func has returned; otherwise
+ * it returns just before the target cpu calls @func.
+ *
+ * You must not call this function with disabled interrupts or from a
+ * hardware interrupt handler or from a bottom half handler.
+ */
+int smp_call_function_mask(cpumask_t mask,
+			   void (*func)(void *), void *info,
+			   int wait)
+{
+	struct call_data_struct data;
+	cpumask_t allbutself;
+	int cpus;
+
+	spin_lock(&call_lock);
+	allbutself =3D cpu_online_map;
+	cpu_clear(smp_processor_id(), allbutself);
+
+	cpus_and(mask, mask, allbutself);
+	cpus =3D cpus_weight(mask);
+	if (!cpus) {
+		spin_unlock(&call_lock);
+		return 0;
+	}
+
+	/* Can deadlock when called with interrupts disabled */
+	WARN_ON(irqs_disabled());
+
+	data.func =3D func;
+	data.info =3D info;
+	atomic_set(&data.started, 0);
+	data.wait =3D wait;
+	if (wait)
+		atomic_set(&data.finished, 0);
+
+	call_data =3D &data;
+	mb(); /* ensure store to call_data precedes setting of
IPI_CALL_FUNC*/
+
+	/* Send a message to other CPUs */
+	if (cpus_equal(mask, allbutself))
+		send_IPI_allbutself(IPI_CALL_FUNC);
+	else
+		send_IPI_mask(mask, IPI_CALL_FUNC);
+
+	/* Wait for response */
+	while (atomic_read(&data.started) !=3D cpus)
+		cpu_relax();
+
+	if (wait)
+		while (atomic_read(&data.finished) !=3D cpus)
+			cpu_relax();
+	call_data =3D NULL;
+
+	spin_unlock(&call_lock);
+	return 0;
+
+}
+EXPORT_SYMBOL(smp_call_function_mask);
+
 /*
  * this function sends a 'generic call function' IPI to all other CPUs
  * in the system.
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

------_=_NextPart_001_01C893E4.F0D3EB6B
Content-Type: application/octet-stream;
	name="0002-IA64-Implement-smp_call_function_mask-for-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0002-IA64-Implement-smp_call_function_mask-for-ia64.patch
Content-Disposition: attachment;
	filename="0002-IA64-Implement-smp_call_function_mask-for-ia64.patch"

RnJvbSBmZTNjNWRlYWMzOTAzM2ZiNzY1MWVjY2U1ZGYzZDFkY2U3ZGQ2NmY3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxIEFwciAyMDA4IDE0OjM4OjIxICswODAwClN1YmplY3Q6IFtQQVRDSF0g
SUE2NDogSW1wbGVtZW50IHNtcF9jYWxsX2Z1bmN0aW9uX21hc2sgZm9yIGlhNjQKClRoaXMgaW50
ZXJmYWNlIHByb3ZpZGVzIG1vcmUgZmxleGlibGUgZnVuY3Rpb25hbGl0eWZvciBzbXAKaW5mcmFz
dHJ1Y3R1cmUuClNpZ25lZC1vZmYtYnk6IFhpYW50YW8gWmhhbmcgPHhpYW50YW8uemhhbmdAaW50
ZWwuY29tPgotLS0KIGFyY2gvaWE2NC9rZXJuZWwvc21wLmMgfCAgIDgyICsrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKwogaW5jbHVkZS9hc20taWE2NC9zbXAu
aCB8ICAgIDMgKysKIDIgZmlsZXMgY2hhbmdlZCwgODUgaW5zZXJ0aW9ucygrKSwgMCBkZWxldGlv
bnMoLSkKCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva2VybmVsL3NtcC5jIGIvYXJjaC9pYTY0L2tl
cm5lbC9zbXAuYwppbmRleCA0ZTQ0NmFhLi45YTlkNGM0IDEwMDY0NAotLS0gYS9hcmNoL2lhNjQv
a2VybmVsL3NtcC5jCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvc21wLmMKQEAgLTIxMyw2ICsyMTMs
MTkgQEAgc2VuZF9JUElfYWxsYnV0c2VsZiAoaW50IG9wKQogICogQ2FsbGVkIHdpdGggcHJlZW1w
dGlvbiBkaXNhYmxlZC4KICAqLwogc3RhdGljIGlubGluZSB2b2lkCitzZW5kX0lQSV9tYXNrKGNw
dW1hc2tfdCBtYXNrLCBpbnQgb3ApCit7CisJdW5zaWduZWQgaW50IGNwdTsKKworCWZvcl9lYWNo
X2NwdV9tYXNrKGNwdSwgbWFzaykgeworCQkJc2VuZF9JUElfc2luZ2xlKGNwdSwgb3ApOworCX0K
K30KKworLyoKKyAqIENhbGxlZCB3aXRoIHByZWVtcHRpb24gZGlzYWJsZWQuCisgKi8KK3N0YXRp
YyBpbmxpbmUgdm9pZAogc2VuZF9JUElfYWxsIChpbnQgb3ApCiB7CiAJaW50IGk7CkBAIC00MDEs
NiArNDE0LDc1IEBAIHNtcF9jYWxsX2Z1bmN0aW9uX3NpbmdsZSAoaW50IGNwdWlkLCB2b2lkICgq
ZnVuYykgKHZvaWQgKmluZm8pLCB2b2lkICppbmZvLCBpbnQKIH0KIEVYUE9SVF9TWU1CT0woc21w
X2NhbGxfZnVuY3Rpb25fc2luZ2xlKTsKIAorLyoqCisgKiBzbXBfY2FsbF9mdW5jdGlvbl9tYXNr
KCk6IFJ1biBhIGZ1bmN0aW9uIG9uIGEgc2V0IG9mIG90aGVyIENQVXMuCisgKiA8bWFzaz4JVGhl
IHNldCBvZiBjcHVzIHRvIHJ1biBvbi4gIE11c3Qgbm90IGluY2x1ZGUgdGhlIGN1cnJlbnQgY3B1
LgorICogPGZ1bmM+IAlUaGUgZnVuY3Rpb24gdG8gcnVuLiBUaGlzIG11c3QgYmUgZmFzdCBhbmQg
bm9uLWJsb2NraW5nLgorICogPGluZm8+CUFuIGFyYml0cmFyeSBwb2ludGVyIHRvIHBhc3MgdG8g
dGhlIGZ1bmN0aW9uLgorICogPHdhaXQ+CUlmIHRydWUsIHdhaXQgKGF0b21pY2FsbHkpIHVudGls
IGZ1bmN0aW9uCisgKgkJaGFzIGNvbXBsZXRlZCBvbiBvdGhlciBDUFVzLgorICoKKyAqIFJldHVy
bnMgMCBvbiBzdWNjZXNzLCBlbHNlIGEgbmVnYXRpdmUgc3RhdHVzIGNvZGUuCisgKgorICogSWYg
QHdhaXQgaXMgdHJ1ZSwgdGhlbiByZXR1cm5zIG9uY2UgQGZ1bmMgaGFzIHJldHVybmVkOyBvdGhl
cndpc2UKKyAqIGl0IHJldHVybnMganVzdCBiZWZvcmUgdGhlIHRhcmdldCBjcHUgY2FsbHMgQGZ1
bmMuCisgKgorICogWW91IG11c3Qgbm90IGNhbGwgdGhpcyBmdW5jdGlvbiB3aXRoIGRpc2FibGVk
IGludGVycnVwdHMgb3IgZnJvbSBhCisgKiBoYXJkd2FyZSBpbnRlcnJ1cHQgaGFuZGxlciBvciBm
cm9tIGEgYm90dG9tIGhhbGYgaGFuZGxlci4KKyAqLworaW50IHNtcF9jYWxsX2Z1bmN0aW9uX21h
c2soY3B1bWFza190IG1hc2ssCisJCQkgICB2b2lkICgqZnVuYykodm9pZCAqKSwgdm9pZCAqaW5m
bywKKwkJCSAgIGludCB3YWl0KQoreworCXN0cnVjdCBjYWxsX2RhdGFfc3RydWN0IGRhdGE7CisJ
Y3B1bWFza190IGFsbGJ1dHNlbGY7CisJaW50IGNwdXM7CisKKwlzcGluX2xvY2soJmNhbGxfbG9j
ayk7CisJYWxsYnV0c2VsZiA9IGNwdV9vbmxpbmVfbWFwOworCWNwdV9jbGVhcihzbXBfcHJvY2Vz
c29yX2lkKCksIGFsbGJ1dHNlbGYpOworCisJY3B1c19hbmQobWFzaywgbWFzaywgYWxsYnV0c2Vs
Zik7CisJY3B1cyA9IGNwdXNfd2VpZ2h0KG1hc2spOworCWlmICghY3B1cykgeworCQlzcGluX3Vu
bG9jaygmY2FsbF9sb2NrKTsKKwkJcmV0dXJuIDA7CisJfQorCisJLyogQ2FuIGRlYWRsb2NrIHdo
ZW4gY2FsbGVkIHdpdGggaW50ZXJydXB0cyBkaXNhYmxlZCAqLworCVdBUk5fT04oaXJxc19kaXNh
YmxlZCgpKTsKKworCWRhdGEuZnVuYyA9IGZ1bmM7CisJZGF0YS5pbmZvID0gaW5mbzsKKwlhdG9t
aWNfc2V0KCZkYXRhLnN0YXJ0ZWQsIDApOworCWRhdGEud2FpdCA9IHdhaXQ7CisJaWYgKHdhaXQp
CisJCWF0b21pY19zZXQoJmRhdGEuZmluaXNoZWQsIDApOworCisJY2FsbF9kYXRhID0gJmRhdGE7
CisJbWIoKTsgLyogZW5zdXJlIHN0b3JlIHRvIGNhbGxfZGF0YSBwcmVjZWRlcyBzZXR0aW5nIG9m
IElQSV9DQUxMX0ZVTkMqLworCisJLyogU2VuZCBhIG1lc3NhZ2UgdG8gb3RoZXIgQ1BVcyAqLwor
CWlmIChjcHVzX2VxdWFsKG1hc2ssIGFsbGJ1dHNlbGYpKQorCQlzZW5kX0lQSV9hbGxidXRzZWxm
KElQSV9DQUxMX0ZVTkMpOworCWVsc2UKKwkJc2VuZF9JUElfbWFzayhtYXNrLCBJUElfQ0FMTF9G
VU5DKTsKKworCS8qIFdhaXQgZm9yIHJlc3BvbnNlICovCisJd2hpbGUgKGF0b21pY19yZWFkKCZk
YXRhLnN0YXJ0ZWQpICE9IGNwdXMpCisJCWNwdV9yZWxheCgpOworCisJaWYgKHdhaXQpCisJCXdo
aWxlIChhdG9taWNfcmVhZCgmZGF0YS5maW5pc2hlZCkgIT0gY3B1cykKKwkJCWNwdV9yZWxheCgp
OworCWNhbGxfZGF0YSA9IE5VTEw7CisKKwlzcGluX3VubG9jaygmY2FsbF9sb2NrKTsKKwlyZXR1
cm4gMDsKKworfQorRVhQT1JUX1NZTUJPTChzbXBfY2FsbF9mdW5jdGlvbl9tYXNrKTsKKwogLyoK
ICAqIHRoaXMgZnVuY3Rpb24gc2VuZHMgYSAnZ2VuZXJpYyBjYWxsIGZ1bmN0aW9uJyBJUEkgdG8g
YWxsIG90aGVyIENQVXMKICAqIGluIHRoZSBzeXN0ZW0uCmRpZmYgLS1naXQgYS9pbmNsdWRlL2Fz
bS1pYTY0L3NtcC5oIGIvaW5jbHVkZS9hc20taWE2NC9zbXAuaAppbmRleCA0ZmE3MzNkLi5lYzVm
MzU1IDEwMDY0NAotLS0gYS9pbmNsdWRlL2FzbS1pYTY0L3NtcC5oCisrKyBiL2luY2x1ZGUvYXNt
LWlhNjQvc21wLmgKQEAgLTM4LDYgKzM4LDkgQEAgaWE2NF9nZXRfbGlkICh2b2lkKQogCXJldHVy
biBsaWQuZi5pZCA8PCA4IHwgbGlkLmYuZWlkOwogfQogCitleHRlcm4gaW50IHNtcF9jYWxsX2Z1
bmN0aW9uX21hc2soY3B1bWFza190IG1hc2ssIHZvaWQgKCpmdW5jKSh2b2lkICopLAorCQkJCSAg
dm9pZCAqaW5mbywgaW50IHdhaXQpOworCiAjZGVmaW5lIGhhcmRfc21wX3Byb2Nlc3Nvcl9pZCgp
CQlpYTY0X2dldF9saWQoKQogCiAjaWZkZWYgQ09ORklHX1NNUAotLSAKMS41LjIKCg==

------_=_NextPart_001_01C893E4.F0D3EB6B--
