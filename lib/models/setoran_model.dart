class SetoranRespons {
  bool? response;
  String? message;
  Data? data;

  SetoranRespons({this.response, this.message, this.data});

  SetoranRespons.fromJson(Map<String, dynamic> json) {
    response = json['response'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response'] = this.response;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Info? info;
  Setoran? setoran;

  Data({this.info, this.setoran});

  Data.fromJson(Map<String, dynamic> json) {
    info = json['info'] != null ? new Info.fromJson(json['info']) : null;
    setoran =
        json['setoran'] != null ? new Setoran.fromJson(json['setoran']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.info != null) {
      data['info'] = this.info!.toJson();
    }
    if (this.setoran != null) {
      data['setoran'] = this.setoran!.toJson();
    }
    return data;
  }
}

class Info {
  String? nama;
  String? nim;
  String? email;
  String? angkatan;
  int? semester;
  DosenPa? dosenPa;

  Info(
      {this.nama,
      this.nim,
      this.email,
      this.angkatan,
      this.semester,
      this.dosenPa});

  Info.fromJson(Map<String, dynamic> json) {
    nama = json['nama'];
    nim = json['nim'];
    email = json['email'];
    angkatan = json['angkatan'];
    semester = json['semester'];
    dosenPa = json['dosen_pa'] != null
        ? new DosenPa.fromJson(json['dosen_pa'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nama'] = this.nama;
    data['nim'] = this.nim;
    data['email'] = this.email;
    data['angkatan'] = this.angkatan;
    data['semester'] = this.semester;
    if (this.dosenPa != null) {
      data['dosen_pa'] = this.dosenPa!.toJson();
    }
    return data;
  }
}

class DosenPa {
  String? nip;
  String? nama;
  String? email;

  DosenPa({this.nip, this.nama, this.email});

  DosenPa.fromJson(Map<String, dynamic> json) {
    nip = json['nip'];
    nama = json['nama'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nip'] = this.nip;
    data['nama'] = this.nama;
    data['email'] = this.email;
    return data;
  }
}

class Setoran {
  InfoDasar? infoDasar;
  List<Ringkasan>? ringkasan;
  List<Detail>? detail;

  Setoran({this.infoDasar, this.ringkasan, this.detail});

  Setoran.fromJson(Map<String, dynamic> json) {
    infoDasar = json['info_dasar'] != null
        ? new InfoDasar.fromJson(json['info_dasar'])
        : null;
    if (json['ringkasan'] != null) {
      ringkasan = <Ringkasan>[];
      json['ringkasan'].forEach((v) {
        ringkasan!.add(new Ringkasan.fromJson(v));
      });
    }
    if (json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail!.add(new Detail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.infoDasar != null) {
      data['info_dasar'] = this.infoDasar!.toJson();
    }
    if (this.ringkasan != null) {
      data['ringkasan'] = this.ringkasan!.map((v) => v.toJson()).toList();
    }
    if (this.detail != null) {
      data['detail'] = this.detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class InfoDasar {
  int? totalWajibSetor;
  int? totalSudahSetor;
  int? totalBelumSetor;
  double? persentaseProgresSetor;

  InfoDasar(
      {this.totalWajibSetor,
      this.totalSudahSetor,
      this.totalBelumSetor,
      this.persentaseProgresSetor});

  InfoDasar.fromJson(Map<String, dynamic> json) {
    totalWajibSetor = json['total_wajib_setor'];
    totalSudahSetor = json['total_sudah_setor'];
    totalBelumSetor = json['total_belum_setor'];
    persentaseProgresSetor = (json['persentase_progres_setor'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_wajib_setor'] = this.totalWajibSetor;
    data['total_sudah_setor'] = this.totalSudahSetor;
    data['total_belum_setor'] = this.totalBelumSetor;
    data['persentase_progres_setor'] = this.persentaseProgresSetor;
    return data;
  }
}

class Ringkasan {
  String? label;
  int? totalWajibSetor;
  int? totalSudahSetor;
  int? totalBelumSetor;
  double? persentaseProgresSetor;

  Ringkasan(
      {this.label,
      this.totalWajibSetor,
      this.totalSudahSetor,
      this.totalBelumSetor,
      this.persentaseProgresSetor});

  Ringkasan.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    totalWajibSetor = json['total_wajib_setor'];
    totalSudahSetor = json['total_sudah_setor'];
    totalBelumSetor = json['total_belum_setor'];
    persentaseProgresSetor = (json['persentase_progres_setor'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['total_wajib_setor'] = this.totalWajibSetor;
    data['total_sudah_setor'] = this.totalSudahSetor;
    data['total_belum_setor'] = this.totalBelumSetor;
    data['persentase_progres_setor'] = this.persentaseProgresSetor;
    return data;
  }
}

class Detail {
  String? id;
  String? nama;
  String? externalId;
  String? namaArab;
  String? label;
  bool? sudahSetor;
  InfoSetoran? infoSetoran;

  Detail(
      {this.id,
      this.nama,
      this.externalId,
      this.namaArab,
      this.label,
      this.sudahSetor,
      this.infoSetoran});

  Detail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    externalId = json['external_id'];
    namaArab = json['nama_arab'];
    label = json['label'];
    sudahSetor = json['sudah_setor'];
    infoSetoran = json['info_setoran'] != null
        ? new InfoSetoran.fromJson(json['info_setoran'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nama'] = this.nama;
    data['external_id'] = this.externalId;
    data['nama_arab'] = this.namaArab;
    data['label'] = this.label;
    data['sudah_setor'] = this.sudahSetor;
    if (this.infoSetoran != null) {
      data['info_setoran'] = this.infoSetoran!.toJson();
    }
    return data;
  }
}

class InfoSetoran {
  String? id;
  String? tglSetoran;
  String? tglValidasi;
  DosenPa? dosenYangMengesahkan;

  InfoSetoran(
      {this.id, this.tglSetoran, this.tglValidasi, this.dosenYangMengesahkan});

  InfoSetoran.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tglSetoran = json['tgl_setoran'];
    tglValidasi = json['tgl_validasi'];
    dosenYangMengesahkan = json['dosen_yang_mengesahkan'] != null
        ? new DosenPa.fromJson(json['dosen_yang_mengesahkan'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tgl_setoran'] = this.tglSetoran;
    data['tgl_validasi'] = this.tglValidasi;
    if (this.dosenYangMengesahkan != null) {
      data['dosen_yang_mengesahkan'] = this.dosenYangMengesahkan!.toJson();
    }
    return data;
  }
}
