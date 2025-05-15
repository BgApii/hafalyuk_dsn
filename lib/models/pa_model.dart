class PaRespons {
  bool? response;
  String? message;
  Data? data;

  PaRespons({this.response, this.message, this.data});

  PaRespons.fromJson(Map<String, dynamic> json) {
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
  String? nip;
  String? nama;
  String? email;
  InfoMahasiswaPa? infoMahasiswaPa;

  Data({this.nip, this.nama, this.email, this.infoMahasiswaPa});

  Data.fromJson(Map<String, dynamic> json) {
    nip = json['nip'];
    nama = json['nama'];
    email = json['email'];
    infoMahasiswaPa = json['info_mahasiswa_pa'] != null
        ? new InfoMahasiswaPa.fromJson(json['info_mahasiswa_pa'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nip'] = this.nip;
    data['nama'] = this.nama;
    data['email'] = this.email;
    if (this.infoMahasiswaPa != null) {
      data['info_mahasiswa_pa'] = this.infoMahasiswaPa!.toJson();
    }
    return data;
  }
}

class InfoMahasiswaPa {
  List<Ringkasan>? ringkasan;
  List<DaftarMahasiswa>? daftarMahasiswa;

  InfoMahasiswaPa({this.ringkasan, this.daftarMahasiswa});

  InfoMahasiswaPa.fromJson(Map<String, dynamic> json) {
    if (json['ringkasan'] != null) {
      ringkasan = <Ringkasan>[];
      json['ringkasan'].forEach((v) {
        ringkasan!.add(new Ringkasan.fromJson(v));
      });
    }
    if (json['daftar_mahasiswa'] != null) {
      daftarMahasiswa = <DaftarMahasiswa>[];
      json['daftar_mahasiswa'].forEach((v) {
        daftarMahasiswa!.add(new DaftarMahasiswa.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.ringkasan != null) {
      data['ringkasan'] = this.ringkasan!.map((v) => v.toJson()).toList();
    }
    if (this.daftarMahasiswa != null) {
      data['daftar_mahasiswa'] =
          this.daftarMahasiswa!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Ringkasan {
  String? tahun;
  int? total;

  Ringkasan({this.tahun, this.total});

  Ringkasan.fromJson(Map<String, dynamic> json) {
    tahun = json['tahun'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tahun'] = this.tahun;
    data['total'] = this.total;
    return data;
  }
}

class DaftarMahasiswa {
  String? email;
  String? nim;
  String? nama;
  String? angkatan;
  int? semester;
  InfoSetoran? infoSetoran;

  DaftarMahasiswa(
      {this.email,
      this.nim,
      this.nama,
      this.angkatan,
      this.semester,
      this.infoSetoran});

  DaftarMahasiswa.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    nim = json['nim'];
    nama = json['nama'];
    angkatan = json['angkatan'];
    semester = json['semester'];
    infoSetoran = json['info_setoran'] != null
        ? new InfoSetoran.fromJson(json['info_setoran'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['nim'] = this.nim;
    data['nama'] = this.nama;
    data['angkatan'] = this.angkatan;
    data['semester'] = this.semester;
    if (this.infoSetoran != null) {
      data['info_setoran'] = this.infoSetoran!.toJson();
    }
    return data;
  }
}

class InfoSetoran {
  int? totalWajibSetor;
  int? totalSudahSetor;
  int? totalBelumSetor;
  double? persentaseProgresSetor;
  String? tglTerakhirSetor;
  String? terakhirSetor;

  InfoSetoran(
      {this.totalWajibSetor,
      this.totalSudahSetor,
      this.totalBelumSetor,
      this.persentaseProgresSetor,
      this.tglTerakhirSetor,
      this.terakhirSetor});

  InfoSetoran.fromJson(Map<String, dynamic> json) {
    totalWajibSetor = json['total_wajib_setor'];
    totalSudahSetor = json['total_sudah_setor'];
    totalBelumSetor = json['total_belum_setor'];
    persentaseProgresSetor = (json['persentase_progres_setor'] as num?)?.toDouble();
    tglTerakhirSetor = json['tgl_terakhir_setor'];
    terakhirSetor = json['terakhir_setor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_wajib_setor'] = this.totalWajibSetor;
    data['total_sudah_setor'] = this.totalSudahSetor;
    data['total_belum_setor'] = this.totalBelumSetor;
    data['persentase_progres_setor'] = this.persentaseProgresSetor;
    data['tgl_terakhir_setor'] = this.tglTerakhirSetor;
    data['terakhir_setor'] = this.terakhirSetor;
    return data;
  }
}
