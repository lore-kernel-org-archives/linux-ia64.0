From: Thierry Reding <thierry.reding@gmail.com>
Date: Mon, 06 Oct 2014 13:52:35 +0000
Subject: [PATCH 3/9] ARM: ixp4xx: Properly override I/O accessors
Message-Id: <1412603561-27653-4-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412603561-27653-1-git-send-email-thierry.reding@gmail.com>
In-Reply-To: <1412603561-27653-1-git-send-email-thierry.reding@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Olof Johansson <olof@lixom.net>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Boyd <sboyd@codeaurora.org>, Sam Ravnborg <sam@ravnborg.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-serial@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

In order to override accessors properly they must be #define'd so that
subsequent generic headers (the one for ARM and finally the architecture
independent one) can properly detect it.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 arch/arm/mach-ixp4xx/include/mach/io.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/arm/mach-ixp4xx/include/mach/io.h b/arch/arm/mach-ixp4xx/include/mach/io.h
index 559c69a47731..b47efdad95f4 100644
--- a/arch/arm/mach-ixp4xx/include/mach/io.h
+++ b/arch/arm/mach-ixp4xx/include/mach/io.h
@@ -226,6 +226,7 @@ static inline void __indirect_readsl(const volatile void __iomem *bus_addr,
  * I/O functions.
  */
 
+#define outb outb
 static inline void outb(u8 value, u32 addr)
 {
 	u32 n, byte_enables, data;
@@ -235,12 +236,14 @@ static inline void outb(u8 value, u32 addr)
 	ixp4xx_pci_write(addr, byte_enables | NP_CMD_IOWRITE, data);
 }
 
+#define outsb outsb
 static inline void outsb(u32 io_addr, const u8 *vaddr, u32 count)
 {
 	while (count--)
 		outb(*vaddr++, io_addr);
 }
 
+#define outw outw
 static inline void outw(u16 value, u32 addr)
 {
 	u32 n, byte_enables, data;
@@ -250,23 +253,27 @@ static inline void outw(u16 value, u32 addr)
 	ixp4xx_pci_write(addr, byte_enables | NP_CMD_IOWRITE, data);
 }
 
+#define outsw outsw
 static inline void outsw(u32 io_addr, const u16 *vaddr, u32 count)
 {
 	while (count--)
 		outw(cpu_to_le16(*vaddr++), io_addr);
 }
 
+#define outl outl
 static inline void outl(u32 value, u32 addr)
 {
 	ixp4xx_pci_write(addr, NP_CMD_IOWRITE, value);
 }
 
+#define outsl outsl
 static inline void outsl(u32 io_addr, const u32 *vaddr, u32 count)
 {
 	while (count--)
 		outl(cpu_to_le32(*vaddr++), io_addr);
 }
 
+#define inb inb
 static inline u8 inb(u32 addr)
 {
 	u32 n, byte_enables, data;
@@ -278,12 +285,14 @@ static inline u8 inb(u32 addr)
 	return data >> (8*n);
 }
 
+#define insb insb
 static inline void insb(u32 io_addr, u8 *vaddr, u32 count)
 {
 	while (count--)
 		*vaddr++ = inb(io_addr);
 }
 
+#define inw inw
 static inline u16 inw(u32 addr)
 {
 	u32 n, byte_enables, data;
@@ -295,12 +304,14 @@ static inline u16 inw(u32 addr)
 	return data>>(8*n);
 }
 
+#define insw insw
 static inline void insw(u32 io_addr, u16 *vaddr, u32 count)
 {
 	while (count--)
 		*vaddr++ = le16_to_cpu(inw(io_addr));
 }
 
+#define inl inl
 static inline u32 inl(u32 addr)
 {
 	u32 data;
@@ -310,6 +321,7 @@ static inline u32 inl(u32 addr)
 	return data;
 }
 
+#define insl insl
 static inline void insl(u32 io_addr, u32 *vaddr, u32 count)
 {
 	while (count--)
-- 
2.1.0

