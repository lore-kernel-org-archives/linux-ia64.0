From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 07 Jan 2004 04:48:32 +0000
Subject: Re: script to check for guaranteed-to-crash-your-app warnings
Message-Id: <16379.36768.630653.2051@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16379.11171.475075.708058@napali.hpl.hp.com>
In-Reply-To: <16379.11171.475075.708058@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 6 Jan 2004 17:56:31 -0800, David Mosberger <davidm@linux.hpl.hp.com> said:

  David> Argh, the situation must be worse than what I reported, since
  David> "evolution" didn't show up at all!  evolution was missed
  David> because lynx by default wraps lines after 80 columns.  I
  David> fixed the fetch-log script and am rerunning it now.  I'm sure
  David> this would be a lot easier to do for someone who has direct
  David> access to the log files...

OK, here is a more credible list of offenders.  Several critical
packages are affected.  I already filed patches for gnumeric and
evolution, so those you don't need to worry about (I listed them for
completeness below).  List of all other affected packages:

	dia
	gnome-iconedit
	gnome-media
	gnumeric
	libgda2
	libgnomedb
	libgsm
	libtk-perl
	metacity-setup
	rep-gtk
	vlc

libgtk-perl looks to be in particularly bad shape.  Perhaps nobody
cares about that one.  libgda2, libgnomedb, metacity-setup, rep-gtk
seem fairly fundamental, on the other hand.

	--david

---
Here is the detailed output:

checking dia.log...
Function `pango_ft2_get_context' implicitly converted to pointer at app_procs.c:396
Function `pango_ft2_get_context' implicitly converted to pointer at app_procs.c:396

checking evolution.log...
Function `strdup' implicitly converted to pointer at e-pilot-util.c:42
Function `e_path_to_physical' implicitly converted to pointer at mail-importer.c:98

checking gnome-iconedit.log...
Function `ie_model_get_pixel' implicitly converted to pointer at grid.c:417
Function `ie_model_get_pixel' implicitly converted to pointer at mode.c:54

checking gnome-media.log...
Function `device_from_name' implicitly converted to pointer at prefs.c:119

checking gnumeric.log...
Function `gtk_menu_item_new_with_label' implicitly converted to pointer at ../../../src/dialogs/dialog-printer-setup.c:846

checking libgda2.log...
Function `gda_type_to_string' implicitly converted to pointer at gda-sqlite-provider.c:675

checking libgnomedb.log...
Function `BONOBO_WINDOW' implicitly converted to pointer at glade-gnomedb.c:53

checking libgsm.log...
Function `fdopen' implicitly converted to pointer at src/toast.c:510

checking libgtk-perl.log...
Function `newSVGtkObjectRef' implicitly converted to pointer at GdkPixbufLoader.c:39
Function `SvGtkObjectRef' implicitly converted to pointer at GdkPixbufLoader.c:58
Function `SvGtkXmHTMLCallbackStruct' implicitly converted to pointer at GtkXmHTML.c:1024
Function `SvGdkImlibImage' implicitly converted to pointer at GnomeCanvasItem.xs:32
Function `newSVGdkImlibImage' implicitly converted to pointer at GnomeCanvasItem.xs:63
Function `newSVGtkObjectRef' implicitly converted to pointer at GnomePrinter.c:40
Function `SvGtkObjectRef' implicitly converted to pointer at GnomePrinter.c:57
Function `newSVDefEnumHash' implicitly converted to pointer at GnomePrinter.c:69
Function `SvGtkObjectRef' implicitly converted to pointer at GnomePrintMasterPreview.c:36
Function `newSVGtkObjectRef' implicitly converted to pointer at GnomePrintMasterPreview.c:49
Function `newSVGtkObjectRef' implicitly converted to pointer at GnomePrinterWidget.c:39
Function `SvGtkObjectRef' implicitly converted to pointer at GnomePrinterWidget.c:57
Function `newSVGtkObjectRef' implicitly converted to pointer at GnomePrinterDialog.c:39
Function `SvGtkObjectRef' implicitly converted to pointer at GnomePrinterDialog.c:57
Function `SvGtkObjectRef' implicitly converted to pointer at GnomePrintDialog.c:34
Function `newSVDefEnumHash' implicitly converted to pointer at GnomePrintDialog.c:46
Function `newSVGtkObjectRef' implicitly converted to pointer at GnomePrintDialog.c:131
Function `newSVGtkObjectRef' implicitly converted to pointer at GnomePrintMaster.c:39
Function `SvGtkObjectRef' implicitly converted to pointer at GnomePrintMaster.c:57

checking metacity-setup.log...
Function `gnome_vfs_get_file_mime_type' implicitly converted to pointer at callbacks.c:68

checking rep-gtk.log...
Function `gnome_geometry_string' implicitly converted to pointer at gnomeui-glue.c:1275

checking vlc.log...
Function `NPP_GetJavaClass' implicitly converted to pointer at support/npunix.c:341
