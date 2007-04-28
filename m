From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Sat, 28 Apr 2007 00:34:03 +0000
Subject: RE: [patch] Support multiple CPUs going through OS_MCA
Message-Id: <A29F7A5700A7EA4380E08C1F68C3B6D802A149C5@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704272129.l3RLT8Ob64391823@clink.americas.sgi.com>
In-Reply-To: <200704272129.l3RLT8Ob64391823@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>+	if (r13 != sos->prev_IA64_KR_CURRENT) {
>+		msg = "inconsistent previous current and r13";
>+		goto no_mod;
>+	}
>+
> 	if (!mca_recover_range(ms->pmsa_iip)) {
>-		if (r13 != sos->prev_IA64_KR_CURRENT) {
>-			msg = "inconsistent previous current and r13";
>-			goto no_mod;
>-		}

Could you explain whey move the r13 check out of mca_recover_range()?


>+		for_each_online_cpu(i) {
>+			if (cpu_isset(i, mca_cpu)) {
>+				monarch_cpu = i;
>+				cpu_clear(i, mca_cpu);	/* wake next cpu
*/

Just a picky comment...Is it better to changed to
+ if (mca_cpu!=0) {
+		for_each_online_cpu(i) {
+			if (cpu_isset(i, mca_cpu)) {
+				monarch_cpu = i;
+				cpu_clear(i, mca_cpu);	/* wake next cpu
*/

it may speed up a bit?. After all in reality, there are few bits set in
mca_cpu. So there is no need to go through all of online cpus.

Thanks.

-Fenghua
