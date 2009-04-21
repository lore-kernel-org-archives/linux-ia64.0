From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 21 Apr 2009 12:15:04 +0000
Subject: Re: ate_resource->lowest_free_index signed or unsigned?
Message-Id: <49EDB8C8.3030501@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <49ECA692.2040007@gmail.com>
In-Reply-To: <49ECA692.2040007@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote:
> Roel Kluin wrote:
>> Jes Sorensen wrote:
>>> Roel Kluin wrote:
>>>> lowest_free_index is unsigned, but in alloc_ate_resource() and
>>>> free_ate_resource() it is treated as signed
>>> I don't thing it's a big issue to be honest, it just means the tests for
>>> lowest_free_index < 0 are no-ops. I would be fine with a patch that
>>> changes it to signed.

> Please make it 'long' or 's64' to keep the size in the struct.

------------------------------>8-------------8<---------------------------------
unsigned lowest_free_index was set in alloc_ate_resource() with the return
value of find_free_ate(), which is -1 when no free ate is found. Since
unsigned, a lowest_free_index of -1, `ate exhaustion', would then not be noticed
in a subsequent call to alloc_ate_resource().

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/arch/ia64/include/asm/sn/pcibr_provider.h b/arch/ia64/include/asm/sn/pcibr_provider.h
index da205b7..636d914 100644
--- a/arch/ia64/include/asm/sn/pcibr_provider.h
+++ b/arch/ia64/include/asm/sn/pcibr_provider.h
@@ -94,7 +94,7 @@
 struct ate_resource{
 	u64 *ate;
 	u64 num_ate;
-	u64 lowest_free_index;
+	s64 lowest_free_index;
 };
 
 struct pcibus_info {
