package io.agora.livedemo.ui.live.fragment;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.ColorInt;
import androidx.annotation.ColorRes;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;
import androidx.annotation.StyleRes;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentTransaction;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.Arrays;
import java.util.List;

import io.agora.chat.uikit.adapter.EaseBaseRecyclerViewAdapter;
import io.agora.chat.uikit.interfaces.OnItemClickListener;
import io.agora.livedemo.R;
import io.agora.livedemo.ui.base.BaseActivity;
import io.agora.livedemo.ui.base.BaseDialogFragment;

public class ListDialogFragment extends BaseDialogFragment {
    private RecyclerView rvDialogList;
    private Button btnCancel;
    private EaseBaseRecyclerViewAdapter adapter;

    private String title;
    private String cancel;
    private int cancelColor;
    private OnDialogItemClickListener itemClickListener;
    private List<String> data;
    private OnDialogCancelClickListener cancelClickListener;
    private int animations;
    private int gravity;


    @Override
    public int getLayoutId() {
        return R.layout.fragment_dialog_list;
    }

    @Override
    public void onStart() {
        super.onStart();
        setDialogParams();
    }

    @Override
    public void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        if (animations != 0) {
            try {
                getDialog().getWindow().setWindowAnimations(animations);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        TextView tvTitle = findViewById(R.id.tv_title);
        View viewDivider = findViewById(R.id.view_divider);
        rvDialogList = findViewById(R.id.rv_dialog_list);
        btnCancel = findViewById(R.id.btn_cancel);

        if (TextUtils.isEmpty(title)) {
            tvTitle.setVisibility(View.GONE);
            viewDivider.setVisibility(View.GONE);
        } else {
            tvTitle.setVisibility(View.VISIBLE);
            viewDivider.setVisibility(View.VISIBLE);
            tvTitle.setText(title);
        }

        if (gravity != -1) {
            tvTitle.setGravity(gravity | Gravity.CENTER_VERTICAL);
        }


        if (TextUtils.isEmpty(cancel)) {
            btnCancel.setText(getString(R.string.cancel));
        } else {
            btnCancel.setText(cancel);
        }

        if (cancelColor != 0) {
            btnCancel.setTextColor(cancelColor);
        }
    }

    @Override
    public void initListener() {
        super.initListener();
        btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
                if (cancelClickListener != null) {
                    cancelClickListener.OnCancel(v);
                }
            }
        });
    }

    @Override
    public void initData() {
        super.initData();
        gravity = -1;
        rvDialogList.setLayoutManager(new LinearLayoutManager(mContext));
        if (adapter == null) {
            adapter = getDefaultAdapter();
        }
        rvDialogList.setAdapter(adapter);

        rvDialogList.addItemDecoration(new DividerItemDecoration(mContext, DividerItemDecoration.VERTICAL));

        adapter.setData(data);

        this.adapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                dismiss();
                if (itemClickListener != null) {
                    itemClickListener.OnItemClick(view, position);
                }
            }
        });
    }

    public static class Builder {
        private BaseActivity context;
        private String title;
        private EaseBaseRecyclerViewAdapter adapter;
        private List<String> data;
        private OnDialogItemClickListener clickListener;
        private String cancel;
        private int cancelColor;
        private OnDialogCancelClickListener cancelClickListener;
        private Bundle bundle;
        private int animations;
        private int gravity;

        public Builder(BaseActivity context) {
            this.context = context;
        }

        public Builder setTitle(@StringRes int title) {
            this.title = context.getString(title);
            return this;
        }

        public Builder setTitle(String title) {
            this.title = title;
            return this;
        }

        public Builder setGravity(int gravity) {
            this.gravity = gravity;
            return this;
        }

        public Builder setAdapter(EaseBaseRecyclerViewAdapter adapter) {
            this.adapter = adapter;
            return this;
        }

        public Builder setData(List<String> data) {
            this.data = data;
            return this;
        }

        public Builder setData(String[] data) {
            this.data = Arrays.asList(data);
            return this;
        }

        public Builder setOnItemClickListener(OnDialogItemClickListener listener) {
            this.clickListener = listener;
            return this;
        }

        public Builder setOnCancelClickListener(@StringRes int cancel, OnDialogCancelClickListener listener) {
            this.cancel = context.getString(cancel);
            this.cancelClickListener = listener;
            return this;
        }

        public Builder setOnCancelClickListener(String cancel, OnDialogCancelClickListener listener) {
            this.cancel = cancel;
            this.cancelClickListener = listener;
            return this;
        }

        public Builder setCancelColorRes(@ColorRes int color) {
            this.cancelColor = ContextCompat.getColor(context, color);
            return this;
        }

        public Builder setCancelColor(@ColorInt int color) {
            this.cancelColor = color;
            return this;
        }

        public Builder setArgument(Bundle bundle) {
            this.bundle = bundle;
            return this;
        }

        public Builder setWindowAnimations(@StyleRes int animations) {
            this.animations = animations;
            return this;
        }

        public ListDialogFragment build() {
            ListDialogFragment fragment = new ListDialogFragment();
            fragment.setTitle(title);
            fragment.setGravity(gravity);
            fragment.setAdapter(adapter);
            fragment.setData(data);
            fragment.setOnItemClickListener(this.clickListener);
            fragment.setCancel(cancel);
            fragment.setCancelColor(cancelColor);
            fragment.setOnCancelClickListener(this.cancelClickListener);
            fragment.setArguments(this.bundle);
            fragment.setWindowAnimations(animations);
            return fragment;
        }

        public ListDialogFragment show() {
            ListDialogFragment fragment = build();
            FragmentTransaction transaction = context.getSupportFragmentManager().beginTransaction().setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE);
            fragment.show(transaction, null);
            return fragment;
        }

    }

    private void setCancelColor(int cancelColor) {
        this.cancelColor = cancelColor;
    }

    private void setWindowAnimations(int animations) {
        this.animations = animations;
    }

    private void setData(List<String> data) {
        this.data = data;
    }

    private void setOnCancelClickListener(OnDialogCancelClickListener cancelClickListener) {
        this.cancelClickListener = cancelClickListener;
    }

    private void setCancel(String cancel) {
        this.cancel = cancel;
    }

    private void setOnItemClickListener(OnDialogItemClickListener clickListener) {
        this.itemClickListener = clickListener;
    }

    private void setAdapter(EaseBaseRecyclerViewAdapter adapter) {
        this.adapter = adapter;
    }


    private EaseBaseRecyclerViewAdapter getDefaultAdapter() {
        DefaultAdapter defaultAdapter = new DefaultAdapter();
        defaultAdapter.setGravity(gravity);
        return defaultAdapter;
    }

    private void setTitle(String title) {
        this.title = title;
    }

    private void setGravity(int gravity) {
        this.gravity = gravity;
    }

    public interface OnDialogItemClickListener {
        void OnItemClick(View view, int position);
    }

    public interface OnDialogCancelClickListener {
        void OnCancel(View view);
    }


    private static class DefaultAdapter extends EaseBaseRecyclerViewAdapter<String> {
        private int gravity;

        public void setGravity(int gravity) {
            this.gravity = gravity;
        }

        @Override
        public MyViewHolder getViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(mContext).inflate(R.layout.dialog_default_list_item, parent, false);
            MyViewHolder viewHolder = new MyViewHolder(view);
            viewHolder.setGravity(gravity);
            return viewHolder;
        }

        private static class MyViewHolder extends ViewHolder<String> {
            private TextView content;
            private int gravity;

            public MyViewHolder(@NonNull View itemView) {
                super(itemView);
                gravity = -1;
            }

            public void setGravity(int gravity) {
                this.gravity = gravity;
            }

            @Override
            public void initView(View itemView) {
                content = findViewById(R.id.tv_title);
                if (-1 != gravity) {
                    content.setGravity(gravity | Gravity.CENTER_VERTICAL);
                }
            }

            @Override
            public void setData(String item, int position) {
                content.setText(item);
            }
        }
    }
}
