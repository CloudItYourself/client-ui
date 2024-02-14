import 'package:ciy_client/widgets/bloc/cluster_url_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClusterURLWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: context.select((CurrentURLBloc bloc) {
      if (bloc.state.currentUrl == null) {
        return '';
      } else {
        return bloc.state.currentUrl!;
      }
    }));

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 250,
        child: Builder(
          builder: (context) {
            return TextField(
              onTapOutside: (text) {
                context.read<CurrentURLBloc>().add(ClusterUrlEvent(controller.text));
              },
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Cluster URL',
                hintText: 'examle.cloud-iy.com',
              ),
            );
          }
        ),
      ),
    );
  }
}
