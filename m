From: xb <xavier.bru@bull.net>
Date: Mon, 03 Apr 2006 14:34:04 +0000
Subject: Re: 2.6.16 not booting due to ACPI  revision 20060127
Message-Id: <4431325C.1040508@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080805080306000801090105"
List-Id: <linux-ia64.vger.kernel.org>
References: <44310983.3070000@bull.net>
In-Reply-To: <44310983.3070000@bull.net>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------080805080306000801090105
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed

xb wrote:

> Hi all,
>
> We have platforms that do not boot in 2.6.16, but boot OK with 2.6.15 
> (loop in ACPI code).
> After some investigations, I found this is due to pci buses that are 
> described in the configuration, but not available in limited 
> configurations.
> These buses have a _STA method, but no _INI method.
> With 2.6.15, the _STA method is run, and as the bus is not present, 
> the bus and all devices behind it are ignored.
> With 2.6.16, as no _INI method is provided for the bus, _STA method is 
> not run, and then we loop when executing methods for devices behind 
> the not present bus.
>
> Having a look to ACPI specification, I could find nowhere the 
> restriction that _STA method is called only when an _INI method is 
> provided for the device:
>
> "6.5.1 _INI (Init)
> ...
> If the _STA method indicates that the device is present, OSPM will 
> evaluate the _INI for the device (if the _INI method exists) and will 
> examine each of the children of the device for _INI methods. If the 
> _STA method indicates that the device is not present, OSPM will not 
> run the _INI and will not examine the children of the device for _INI 
> methods. "
>
>
> traces -----------------------------------------------
>
>
> Device PC11
> 000060e4:  02 . .  Name _HID
> 000060e9:  03 . . .  PNP0A03  PCI Bus  0x030ad041
> 000060ee:  02 . .  Name _UID
> 000060f3:  03 . . .  0x0b
> 000060f5:  02 . .  Name _ADR
> 000060fa:  03 . . .  0x00
> 000060fc:  02 ---- 'PCI bus number setup by the BIOS'  Method _BBN
> 00006102:  03 . . .  0x00
> 00006103:  03 . . .  Return
> 00006104:  04 . . . .  path: \_SB_.CSFF.IO15.B1__
> 00006117:  02 ---- 'Dynamic_Statu'  Method _STA
> 0000611d:  03 . . .  0x00
> 0000611e:  03 . . .  If
> 00006120:  04 . . . .  LEqual
> 00006121:  05 . . . . .  path: \_SB_.CSFF.IO11.HUBD
> 00006134:  05 . . . . .  0x00
> 00006136:  04 . . . .  Return
> 00006137:  05 . . . . .  0x0f
> 00006139:  03 . . .  Return
> 0000613a:  04 . . . .  0x00
> 0000613c:  02 ---- 'Current Resource Setting'  Method _CRS
> 00006142:  03 . . .  0x00
> 00006143:  03 . . .  Return
> 00006144:  04 . . . .  path: \_SB_.HLRS
> 0000614e:  03 . . .  0x01
> 00006150:  03 . . .  0x01
> 00006152:  02
>
I checked that the following patch fixes the problem:

--- linux-2.6.16-old/drivers/acpi/namespace/nsinit.c    2006-03-31 
18:26:23.000000000 +0200
+++ linux-2.6.16-new/drivers/acpi/namespace/nsinit.c    2006-04-03 
14:57:28.000000000 +0200
@@ -362,19 +362,6 @@ acpi_ns_init_one_device(acpi_handle obj_
     info->device_count++;
 
     /*
-     * Check if the _INI method exists for this device -
-     * if _INI does not exist, there is no need to run _STA
-     * No _INI means device requires no initialization
-     */
-    status = acpi_ns_search_node(*ACPI_CAST_PTR(u32, METHOD_NAME__INI),
-                     device_node, ACPI_TYPE_METHOD, &ini_node);
-    if (ACPI_FAILURE(status)) {
-        /* No _INI method found - move on to next device */
-
-        return_ACPI_STATUS(AE_OK);
-    }
-
-    /*
      * Run _STA to determine if we can run _INI on the device -
      * the device must be present before _INI can be run.
      * However, _STA is not required - assume device present if no _STA
@@ -405,6 +392,17 @@ acpi_ns_init_one_device(acpi_handle obj_
     }
 
     /*
+     * Check if the _INI method exists for this device -
+     * No _INI means device requires no initialization
+     */
+    status = acpi_ns_search_node(*ACPI_CAST_PTR(u32, METHOD_NAME__INI),
+                     device_node, ACPI_TYPE_METHOD, &ini_node);
+    if (ACPI_FAILURE(status)) {
+        /* No _INI method found - move on to next device */
+        return_ACPI_STATUS(AE_OK);
+    }
+
+    /*
      * The device is present and _INI exists. Run the _INI method.
      * (We already have the _INI node from above)
      */


--------------080805080306000801090105
Content-Transfer-Encoding: 7bit
Content-Type: text/x-vcard; charset=utf-8;
 name="xavier.bru.vcf"
Content-Disposition: attachment;
 filename="xavier.bru.vcf"

begin:vcard
fn:Xavier Bru
n:Bru;Xavier
adr:;;1 rue de Provence, BP 208;38432 Echirolles Cedex;;;France
email;internet:Xavier.Bru@bull.net
title:BULL/DT/Open Software/linux/ia64
tel;work:+33 (0)4 76 29 77 45
tel;fax:+33 (0)4 76 29 77 70 
x-mozilla-html:TRUE
url:http://www.bull.com
version:2.1
end:vcard


--------------080805080306000801090105--
