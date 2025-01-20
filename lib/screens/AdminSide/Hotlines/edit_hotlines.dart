import 'package:flutter/material.dart';
import 'package:saludko/screens/AdminSide/Hotlines/hotlines_model.dart';
import 'package:saludko/screens/AdminSide/Hotlines/hotlines_service.dart';

class EditHotlineScreen extends StatefulWidget {
  final Hotline? hotline;

  const EditHotlineScreen({super.key, this.hotline});

  @override
  _EditHotlineScreenState createState() => _EditHotlineScreenState();
}

class _EditHotlineScreenState extends State<EditHotlineScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, primaryContact, secondaryContact, description;

  @override
  void initState() {
    super.initState();
    name = widget.hotline?.name ?? '';
    primaryContact = widget.hotline?.primaryContact ?? '';
    secondaryContact = widget.hotline?.secondaryContact ?? '';
    description = widget.hotline?.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.hotline != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Hotline' : 'Add Hotline'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                initialValue: primaryContact,
                decoration: const InputDecoration(labelText: 'Primary Contact'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a primary contact' : null,
                onSaved: (value) => primaryContact = value!,
              ),
              TextFormField(
                initialValue: secondaryContact,
                decoration:
                    const InputDecoration(labelText: 'Secondary Contact'),
                onSaved: (value) => secondaryContact = value ?? '',
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final hotline = Hotline(
                      id: widget.hotline?.id ?? '',
                      name: name,
                      primaryContact: primaryContact,
                      secondaryContact: secondaryContact,
                      description: description,
                    );
                    if (isEditing) {
                      HotlinesService().updateHotline(hotline);
                    } else {
                      HotlinesService().addHotline(hotline);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
