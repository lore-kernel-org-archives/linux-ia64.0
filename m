From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 19 Jul 2002 06:54:09 +0000
Subject: Re: [Linux-ia64] [PATCH] make xconfig broken in ia64-020622
Message-Id: <marc-linux-ia64-105590701905783@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905745@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 10 Jul 2002 18:06:03 +0200 (DFT), 
Xavier Bru <Xavier.Bru@bull.net> wrote:
>Unfortunatly, there are more things broken with make xconfig:
>
>. multiple conditions are not handled by tkparse:
>
>eg: unable to set CONFIG_IA64_MCA when CONFIG_IA64_DIG is set.
>
>if [ "$CONFIG_IA64_GENERIC" = "y" ] || [ "$CONFIG_IA64_DIG" = "y" ] \
>   || [ "$CONFIG_IA64_HP_ZX1" = "y" ]; then
>	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
>	define_bool CONFIG_PM y
>fi
>
>. block device options are not generated in 2.4.18:
>
>ERROR - Attempting to write value for unconfigured variable (CONFIG_BLK_DEV_LOOP).
>ERROR - Attempting to write value for unconfigured variable (CONFIG_BLK_DEV_NBD).
>ERROR - Attempting to write value for unconfigured variable (CONFIG_BLK_DEV_RAM).

Documentation/kbuild/config-language.txt: Config Language is not 'bash'.

Index: 18.95/arch/ia64/config.in
--- 18.95/arch/ia64/config.in Thu, 09 May 2002 12:00:25 +1000 kaos (linux-2.4/s/c/38_config.in 1.1.2.1.2.2.3.1.1.6 644)
+++ 18.95(w)/arch/ia64/config.in Fri, 19 Jul 2002 16:38:02 +1000 kaos (linux-2.4/s/c/38_config.in 1.1.2.1.2.2.3.1.1.6 644)
@@ -78,13 +78,12 @@ if [ "$CONFIG_MCKINLEY" = "y" ]; then
 	fi
 fi
 
-if [ "$CONFIG_IA64_GENERIC" = "y" ] || [ "$CONFIG_IA64_DIG" = "y" ] \
-   || [ "$CONFIG_IA64_HP_ZX1" = "y" ]; then
+if [ "$CONFIG_IA64_GENERIC" = "y" -o "$CONFIG_IA64_DIG" = "y" -o "$CONFIG_IA64_HP_ZX1" = "y" ]; then
 	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
 	define_bool CONFIG_PM y
 fi
 
-if [ "$CONFIG_IA64_SGI_SN1" = "y" ] || [ "$CONFIG_IA64_SGI_SN2" = "y" ]; then
+if [ "$CONFIG_IA64_SGI_SN1" = "y" -o "$CONFIG_IA64_SGI_SN2" = "y" ]; then
 	define_bool CONFIG_IA64_SGI_SN y
 	bool '  Enable extra debugging code' CONFIG_IA64_SGI_SN_DEBUG n
 	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN_SIM
@@ -143,6 +142,10 @@ fi
 
 if [ "$CONFIG_IA64_HP_SIM" = "n" ]; then
 
+define_tristate CONFIG_BLK_DEV_LOOP n
+define_tristate CONFIG_BLK_DEV_NBD n
+define_tristate CONFIG_BLK_DEV_RAM n
+
 source drivers/mtd/Config.in
 source drivers/pnp/Config.in
 source drivers/block/Config.in


